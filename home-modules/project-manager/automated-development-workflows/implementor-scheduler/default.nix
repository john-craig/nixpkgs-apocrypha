{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.evak.project-manager.automated-development-workflows.implementor-scheduler;
  packageFor = name:
    if builtins.hasAttr name pkgs
    then builtins.getAttr name pkgs
    else null;
  upstreamType = lib.types.submodule ({...}: {
    options = {
      url = lib.mkOption {
        type = lib.types.strMatching "(https://|ssh://|git@)[^[:space:]]+";
        description = "Git upstream URL for one scheduled repository.";
      };
      provider = lib.mkOption {
        type = lib.types.enum ["auto" "github" "gitea"];
        default = "auto";
        description = "Provider passed to openspec-implementor.";
      };
      baseBranch = lib.mkOption {
        type = lib.types.strMatching "[A-Za-z0-9._/-]+";
        default = "main";
        description = "Base branch passed to openspec-implementor.";
      };
    };
  });
  upstreamArgs = lib.concatMapStringsSep "\n" (upstream:
    "  ${lib.escapeShellArg "${upstream.url}|${upstream.provider}|${upstream.baseBranch}"}") cfg.upstreams;
  model = if cfg.model == null then "" else cfg.model;
  workRootArg = lib.optionalString (cfg.workRoot != null) "--work-root ${lib.escapeShellArg cfg.workRoot}";
  keepWorktreeArg = lib.optionalString cfg.keepWorktree "--keep-worktree";
  scheduler = pkgs.writeShellApplication {
    name = "openspec-implementor-scheduler";
    runtimeInputs = lib.filter (package: package != null) [
      cfg.implementorPackage
      cfg.flockPackage
    ];
    text = ''
      set -euo pipefail
      umask 077

      state_file=${lib.escapeShellArg cfg.stateFile}
      lock_file=${lib.escapeShellArg cfg.lockFile}
      state_file="''${state_file//%S/''${XDG_STATE_HOME:-$HOME/.local/state}}"
      lock_file="''${lock_file//%t/''${XDG_RUNTIME_DIR:-$HOME/.cache}}"
      retry_on_failure=${lib.boolToString cfg.retryOnFailure}
      model=${lib.escapeShellArg model}
      mkdir -p "$(dirname "$state_file")" "$(dirname "$lock_file")"

      exec 9>"$lock_file"
      if ! flock -n 9; then
        printf '%s\n' 'openspec-implementor-scheduler: skipped; a previous run is still active'
        exit 0
      fi

      upstreams=(
      ${upstreamArgs}
      )
      count=''${#upstreams[@]}
      [[ "$count" -gt 0 ]] || {
        printf '%s\n' 'openspec-implementor-scheduler: no upstream repositories configured' >&2
        exit 2
      }

      read_cursor() {
        local version="" next_index=""
        if [[ -f "$state_file" ]]; then
          while IFS='=' read -r key value; do
            case "$key" in
              version) version="$value" ;;
              next_index) next_index="$value" ;;
            esac
          done <"$state_file"
        fi
        if [[ "$version" != 1 || ! "$next_index" =~ ^[0-9]+$ || "$next_index" -ge "$count" ]]; then
          printf '%s\n' 'openspec-implementor-scheduler: resetting invalid or missing cursor state' >&2
          next_index=0
        fi
        printf '%s\n' "$next_index"
      }

      write_cursor() {
        local next_index="$1"
        local state_dir tmp_state
        state_dir=$(dirname "$state_file")
        tmp_state=$(mktemp "$state_dir/.scheduler-state.XXXXXX")
        chmod 600 "$tmp_state"
        printf 'version=1\nnext_index=%s\n' "$next_index" >"$tmp_state"
        mv -f "$tmp_state" "$state_file"
      }

      cursor=$(read_cursor)
      for ((attempt=0; attempt<count; attempt++)); do
        index=$(( (cursor + attempt) % count ))
        IFS='|' read -r upstream provider base_branch <<<"''${upstreams[$index]}"
        next_index=$(( (index + 1) % count ))
        write_cursor "$next_index"
        printf 'openspec-implementor-scheduler: selected %s\n' "$upstream"

        output_file=$(mktemp "$(dirname "$state_file")/.implementor-output.XXXXXX")
        status_file=$(mktemp "$(dirname "$state_file")/.implementor-status.XXXXXX")
        cleanup_output() { rm -f "$output_file" "$status_file"; }
        trap cleanup_output RETURN
        model_args=()
        [[ -z "$model" ]] || model_args=(--model "$model")
        if ${cfg.implementorPackage}/bin/openspec-implementor \
          --upstream "$upstream" \
          --provider "$provider" \
          --base "$base_branch" \
          "''${model_args[@]}" \
          --status-file "$status_file" \
          ${workRootArg} \
          ${keepWorktreeArg} >"$output_file" 2>&1; then
          cat "$output_file"
          result=$(cat "$status_file" 2>/dev/null || true)
          if [[ "$result" == no-work ]] || {
            [[ -z "$result" ]] &&
              grep -Eq 'No active OpenSpec changes found\.|No eligible OpenSpec changes without pending pull requests\.' "$output_file"
          }; then
            printf 'openspec-implementor-scheduler: no eligible work in %s; trying next repository\n' "$upstream"
            trap - RETURN
            cleanup_output
            continue
          fi
          printf 'openspec-implementor-scheduler: implementation completed for %s\n' "$upstream"
          exit 0
        fi

        cat "$output_file"
        if [[ "$retry_on_failure" == true ]]; then
          write_cursor "$index"
          printf 'openspec-implementor-scheduler: restored %s as the next repository after failure\n' "$upstream" >&2
        fi
        printf 'openspec-implementor-scheduler: implementation failed for %s\n' "$upstream" >&2
        exit 1
      done

      printf '%s\n' 'openspec-implementor-scheduler: no eligible work in configured repositories'
    '';
  };
in {
  options.evak.project-manager.automated-development-workflows.implementor-scheduler = {
    enable = lib.mkEnableOption "periodic OpenSpec implementor scheduling";
    upstreams = lib.mkOption {
      type = lib.types.listOf upstreamType;
      default = [];
      description = "Ordered upstream repositories considered in round-robin order.";
    };
    interval = lib.mkOption {
      type = lib.types.strMatching "[0-9]+(ms|s|min|h|d|weeks?)";
      default = "6h";
      description = "systemd user timer interval.";
    };
    persistent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Replay a missed timer activation after the user session returns.";
    };
    retryOnFailure = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Retry a failed repository before advancing to the next repository.";
    };
    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional OpenCode model passed to openspec-implementor.";
    };
    workRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional parent directory for implementor worktrees.";
    };
    keepWorktree = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Preserve implementor worktrees after failures.";
    };
    stateFile = lib.mkOption {
      type = lib.types.str;
      default = "%S/evak-openspec-implementor-scheduler/state";
      description = "Private scheduler cursor state path.";
    };
    lockFile = lib.mkOption {
      type = lib.types.str;
      default = "%t/evak-openspec-implementor-scheduler.lock";
      description = "Process lock path used to skip overlapping periods.";
    };
    implementorPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "openspec-implementor";
      description = "openspec-implementor executable package.";
    };
    flockPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "util-linux";
      description = "Package providing the flock executable.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.upstreams != [];
        message = "implementor-scheduler requires at least one upstream repository.";
      }
      {
        assertion = cfg.implementorPackage != null;
        message = "implementor-scheduler requires an openspec-implementor package.";
      }
      {
        assertion = cfg.flockPackage != null;
        message = "implementor-scheduler requires a package providing flock.";
      }
    ];
    home.packages = [scheduler];
    systemd.user.services."evak-openspec-implementor-scheduler" = {
      Unit.Description = "Run the OpenSpec implementor scheduler";
      Service = {
        Type = "oneshot";
        ExecStart = "${scheduler}/bin/openspec-implementor-scheduler";
      };
    };
    systemd.user.timers."evak-openspec-implementor-scheduler" = {
      Unit.Description = "Periodically run the OpenSpec implementor scheduler";
      Timer = {
        OnBootSec = cfg.interval;
        OnUnitActiveSec = cfg.interval;
        Persistent = cfg.persistent;
        Unit = "evak-openspec-implementor-scheduler.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}

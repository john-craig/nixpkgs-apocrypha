{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.evak.project-manager.automated-development-workflows.implementor;
  packageFor = name:
    if builtins.hasAttr name pkgs
    then builtins.getAttr name pkgs
    else null;
  agentNames = [
    "default"
    "developer"
    "deployment-specialist"
    "software-architect"
    "systems-architect"
    "orchestrator"
    "audiovisual-design-assistant"
    "disk-jockey"
    "librarian"
    "market-researcher"
    "note-taker"
    "project-manager"
    "remote-systems-diagnostics-assistant"
    "researcher"
    "retrospective"
    "toolsmith"
    "voice-assistant"
  ];
  implementor = pkgs.writeShellApplication {
    name = "openspec-implementor";
    runtimeInputs = lib.filter (package: package != null) [
      cfg.gitPackage
      cfg.jqPackage
      cfg.openspecPackage
      cfg.opencodeAgentPackage
      cfg.ghPackage
      cfg.teaPackage
    ];
    text = ''
      set -euo pipefail

      usage() {
        cat >&2 <<'EOF'
      Usage: openspec-implementor --upstream URL [OPTIONS]

      Options:
        --change NAME       Implement one exact OpenSpec change
        --force              Ignore an existing pending pull request
        --provider NAME      Override provider inference (github or gitea)
        --base BRANCH       Override the upstream default branch
        --work-root PATH     Parent directory for temporary workflow state
        --keep-worktree      Preserve temporary state after a failure
        --help               Show this help
      EOF
      }

      error() {
        printf 'openspec-implementor: %s\n' "$*" >&2
        exit 1
      }

      upstream=""
      requested_change=""
      provider="${cfg.provider}"
      base_branch="${cfg.baseBranch}"
      base_override=false
      work_root="${if cfg.workRoot == null then "" else cfg.workRoot}"
      keep_worktree="${lib.boolToString cfg.keepWorktree}"

      while (($# > 0)); do
        case "$1" in
          --upstream)
            (($# >= 2)) || error '--upstream requires a URL'
            upstream="$2"
            shift 2
            ;;
          --change)
            (($# >= 2)) || error '--change requires a name'
            requested_change="$2"
            shift 2
            ;;
          --force)
            force=true
            shift
            ;;
          --provider)
            (($# >= 2)) || error '--provider requires github or gitea'
            provider="$2"
            shift 2
            ;;
          --base)
            (($# >= 2)) || error '--base requires a branch'
            base_branch="$2"
            base_override=true
            shift 2
            ;;
          --work-root)
            (($# >= 2)) || error '--work-root requires a directory'
            work_root="$2"
            shift 2
            ;;
          --keep-worktree)
            keep_worktree=true
            shift
            ;;
          --help|-h)
            usage
            exit 0
            ;;
          *)
            error "unknown argument: $1"
            ;;
        esac
      done

      : "''${force:=false}"
      : "''${keep_worktree:=false}"

      [[ -n "$upstream" ]] || error '--upstream is required'
      provider_override="$provider"
      if [[ "$provider" == auto ]]; then
        if [[ "$upstream" == *github.com* ]]; then
          provider=github
        else
          provider=gitea
        fi
      fi
      [[ "$provider" == github || "$provider" == gitea ]] ||
        error "unsupported provider: $provider"
      [[ "$base_branch" =~ ^[A-Za-z0-9._/-]+$ ]] ||
        error "invalid base branch: $base_branch"
      [[ "$upstream" =~ ^(https://|ssh://|git@)[^[:space:]]+ ]] ||
        error "invalid upstream URL: $upstream"
      if [[ "$provider" == github && "$upstream" != *github.com* && "$provider_override" != github ]]; then
        error 'GitHub provider requires a github.com upstream or --provider github'
      fi
      command -v git >/dev/null || error 'Git is not available on PATH'
      command -v jq >/dev/null || error 'jq is not available on PATH'
      command -v openspec >/dev/null || error 'OpenSpec is not available on PATH'
      command -v opencode-agent >/dev/null || error 'opencode-agent is not available on PATH'

      case "$upstream" in
        https://*/*/*|ssh://*/*/*|git@*:*/*) ;;
        *) error "cannot derive repository identity from upstream URL: $upstream" ;;
      esac

      case "$upstream" in
        https://*|ssh://*)
          repository_path="''${upstream#*://}"
          repository_path="''${repository_path#*/}"
          ;;
        git@*:*)
          repository_path="''${upstream#*:}"
          ;;
        *)
          error "cannot derive owner/repository from upstream URL: $upstream"
          ;;
      esac
      repository_path="''${repository_path#/}"
      repository_path="''${repository_path%.git}"
      [[ "$repository_path" == */* ]] ||
        error "cannot derive owner/repository from upstream URL: $upstream"

      if [[ "$base_override" != true ]]; then
        remote_head=$(git ls-remote --symref "$upstream" HEAD 2>/dev/null |
          awk '$1 == "ref:" && $2 ~ /^refs\/heads\// {sub("refs/heads/", "", $2); print $2; exit}') ||
          error 'unable to determine the upstream default branch; use --base'
        [[ -n "$remote_head" ]] && base_branch="$remote_head"
      fi

      if [[ -n "$work_root" ]]; then
        [[ -d "$work_root" ]] || error "work root does not exist: $work_root"
        work_parent="$work_root"
      else
        work_parent="''${TMPDIR:-/tmp}"
      fi
      work_dir=$(mktemp -d "$work_parent/openspec-implementor.XXXXXX")
      repository_dir="$work_dir/repository"
      agent_worktree="$work_dir/worktree"
      cleanup() {
        status=$?
        if [[ "$status" -ne 0 && "$keep_worktree" == true ]]; then
          printf 'Preserved failed workflow state at %s\n' "$work_dir" >&2
          trap - EXIT
          return "$status"
        fi
        rm -rf "$work_dir"
        return "$status"
      }
      trap cleanup EXIT

      git clone "$upstream" "$repository_dir" >/dev/null
      git -C "$repository_dir" fetch origin "$base_branch:refs/remotes/origin/$base_branch" >/dev/null
      cd "$repository_dir"

      if [[ -n "$requested_change" ]]; then
        [[ "$requested_change" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] ||
          error "invalid OpenSpec change name: $requested_change"
        candidates=("$requested_change")
      else
        mapfile -t candidates < <(
          openspec list --changes --json |
            jq -r 'if type == "array" then .[]?.name elif .changes then .changes[]?.name else empty end' |
            sort -u
        )
      fi

      if ((''${#candidates[@]} == 0)); then
        printf '%s\n' 'No active OpenSpec changes found.'
        exit 0
      fi

      status_for_change() {
        local change="$1"
        local status
        status=$(openspec status --change "$change" --json) || return 1
        jq -e '(.isPlanningComplete == true) and (.isComplete == true)' >/dev/null <<<"$status"
      }

      pending_pr() {
        local branch="$1"
        local result
        case "$provider" in
          github)
            command -v gh >/dev/null || error 'gh is required for GitHub publication'
            result=$(gh pr list --repo "$repository_path" --head "$branch" --state open --json number 2>/dev/null) ||
              error "unable to query GitHub pull requests for $branch"
            jq -e 'length > 0' >/dev/null <<<"$result"
            ;;
          gitea)
            command -v tea >/dev/null || error 'tea is required for Gitea publication'
            result=$(tea pulls ls --repo "$repository_path" --state open --head "$branch" --output json 2>/dev/null) ||
              error "unable to query Gitea pull requests for $branch"
            jq -e 'length > 0' >/dev/null <<<"$result"
            ;;
        esac
      }

      selected_change=""
      for candidate in "''${candidates[@]}"; do
        if ! status_for_change "$candidate"; then
          if [[ -n "$requested_change" ]]; then
            error "OpenSpec change is not ready for implementation: $candidate"
          fi
          continue
        fi
        branch="feature/$candidate"
        if pending_pr "$branch"; then
          if [[ -n "$requested_change" && "$force" != true ]]; then
            error "a pending pull request already exists for $branch; use --force to continue"
          fi
          if [[ "$force" != true ]]; then
            printf 'Skipping %s because %s has a pending pull request.\n' "$candidate" "$branch" >&2
            continue
          fi
        fi
        selected_change="$candidate"
        break
      done

      [[ -n "$selected_change" ]] || {
        printf '%s\n' 'No eligible OpenSpec changes without pending pull requests.'
        exit 0
      }

      branch="feature/$selected_change"
      git -C "$repository_dir" worktree add -b "$branch" "$agent_worktree" "origin/$base_branch" >/dev/null

      selected_agent=developer
      for agent in ${lib.concatStringsSep " " agentNames}; do
        if [[ "$selected_change" == "$agent"-* ]]; then
          selected_agent="$agent"
          break
        fi
      done

      prompt=$(cat <<EOF
      Implement the OpenSpec change '$selected_change' in this repository.

      Inspect the repository and the change artifacts before editing. Implement
      every required task, run focused tests and relevant repository checks, and
      preserve unrelated work. When implementation and validation are complete,
      run: openspec archive $selected_change --yes

      Do not commit, push, open a pull request, deploy, mutate external systems,
      or change unrelated files. The calling workflow handles publication. If
      required information is missing or validation fails, report the blocker
      and leave the worktree in a diagnosable state.
      EOF
      )

      opencode-agent --agent "$selected_agent" --directory "$agent_worktree" --prompt "$prompt"
      [[ ! -d "$agent_worktree/openspec/changes/$selected_change" ]] ||
        error "OpenSpec change was not archived: $selected_change"
      archived_change=$(find "$agent_worktree/openspec/changes/archive" -mindepth 1 -maxdepth 1 \
        -type d -name "*-$selected_change" -print -quit)
      [[ -n "$archived_change" ]] ||
        error "archived OpenSpec change could not be found: $selected_change"
      git -C "$agent_worktree" diff --check
      [[ "$(git -C "$agent_worktree" branch --show-current)" == "$branch" ]] ||
        error "worktree is not on expected branch: $branch"
      git -C "$agent_worktree" add --all
      git -C "$agent_worktree" diff --cached --check
      git -C "$agent_worktree" diff --cached --quiet && error 'agent produced no changes to publish'
      git -C "$agent_worktree" commit -m "Implement OpenSpec change $selected_change" >/dev/null
      git -C "$agent_worktree" push --set-upstream origin "$branch" >/dev/null

      if pending_pr "$branch"; then
        case "$provider" in
          github)
            gh pr list --repo "$repository_path" --head "$branch" --state open --json url --jq '.[0].url'
            ;;
          gitea)
            tea pulls ls --repo "$repository_path" --state open --head "$branch" --output json |
              jq -r '.[0].html_url // .[0].url // .[0].web_url'
            ;;
        esac
        exit 0
      fi

      title="Implement OpenSpec change $selected_change"
      body="Implements OpenSpec change \`$selected_change\` from $upstream."
      case "$provider" in
        github)
          gh pr create --repo "$repository_path" --head "$branch" --base "$base_branch" --title "$title" --body "$body"
          ;;
        gitea)
          tea pulls create --repo "$repository_path" --head "$branch" --base "$base_branch" --title "$title" --description "$body"
          ;;
      esac
    '';
  };
in {
  options.evak.project-manager.automated-development-workflows.implementor = {
    enable = lib.mkEnableOption "OpenSpec implementation workflow";
    gitPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "git";
      description = "Git package used for repository and worktree operations.";
    };
    jqPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "jq";
      description = "jq package used to parse OpenSpec and provider JSON.";
    };
    openspecPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "openspec";
      description = "OpenSpec CLI package used for change lifecycle operations.";
    };
    opencodeAgentPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "opencode-agent";
      description = "OpenCode agent runner package.";
    };
    ghPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "gh";
      description = "GitHub CLI package used for GitHub publication.";
    };
    teaPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = packageFor "tea";
      description = "Tea package used for Gitea publication.";
    };
    provider = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "github"
        "gitea"
      ];
      default = "auto";
      description = "Provider selection; auto infers GitHub or Gitea from the URL.";
    };
    baseBranch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Default branch override; remote HEAD is used when unchanged.";
    };
    workRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Parent directory for temporary implementor worktrees.";
    };
    keepWorktree = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Preserve temporary state after a failed workflow.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.gitPackage != null;
        message = "implementor requires Git; set evak.project-manager.automated-development-workflows.implementor.gitPackage.";
      }
      {
        assertion = cfg.jqPackage != null;
        message = "implementor requires jq; set evak.project-manager.automated-development-workflows.implementor.jqPackage.";
      }
      {
        assertion = cfg.openspecPackage != null;
        message = "implementor requires OpenSpec; set evak.project-manager.automated-development-workflows.implementor.openspecPackage.";
      }
      {
        assertion = cfg.opencodeAgentPackage != null;
        message = "implementor requires opencode-agent; set evak.project-manager.automated-development-workflows.implementor.opencodeAgentPackage.";
      }
    ];
    home.packages = [ implementor ];
  };
}

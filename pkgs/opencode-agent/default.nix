{ lib, pkgs }:
let
  placeholderOpenCode = pkgs.writeShellScriptBin "opencode-package-placeholder" "exit 0";
  moduleEval = pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      ({ lib, ... }: {
        options.assertions = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              assertion = lib.mkOption { type = lib.types.bool; };
              message = lib.mkOption { type = lib.types.str; };
            };
          });
          default = [ ];
        };
        options.home.file = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              source = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
              };
              text = lib.mkOption {
                type = lib.types.nullOr lib.types.lines;
                default = null;
              };
            };
          });
          default = { };
        };
        options.home.packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };
      })
      ../../home-modules/opencode-agents
      ({ ... }: {
        config.evak.opencode-agents = {
          enable = true;
          opencodePackage = placeholderOpenCode;
        };
      })
    ];
  };
  environmentPrefix = ".config/opencode/environments/";
  environmentFiles = lib.filterAttrs
    (path: _: lib.hasPrefix environmentPrefix path)
    moduleEval.config.home.file;
  relativePath = path: lib.removePrefix environmentPrefix path;
  copyFile = path: file:
    let
      destination = "environments/${relativePath path}";
      content =
        if file.source != null
        then "cp -L ${lib.escapeShellArg file.source} \"$out/${destination}\""
        else "printf '%s' ${lib.escapeShellArg file.text} > \"$out/${destination}\"";
    in ''
      install -d "$(dirname "$out/${destination}")"
      ${content}
    '';
  promptRewrites = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (path: file:
      let
        relative = relativePath path;
        agent = lib.head (lib.splitString "/" relative);
        configPath = "environments/${agent}.json";
      in
      lib.optionalString (lib.hasSuffix "/prompt.md" relative && file.source != null)
        ''sed -i "s#${toString file.source}#$out/environments/${relative}#g" "$out/${configPath}"''
    )
    environmentFiles);
  environments = pkgs.runCommand "opencode-agent-environments" { } ''
    set -euo pipefail
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList copyFile environmentFiles)}
    ${promptRewrites}
    find "$out/environments" -type f -name '*.json' -exec sed -i 's#/home/evak#{env:HOME}#g; s#/run/user/1000#{env:XDG_RUNTIME_DIR}#g' {} +
  '';
in
pkgs.writeShellApplication {
  name = "opencode-agent";
  text = ''
    set -euo pipefail

    environment_root="''${OPENCODE_AGENT_ENVIRONMENT_ROOT:-${environments}/environments}"
    agent=""
    directory=""
    prompt=""

    usage() {
      printf '%s\n' 'Usage: opencode-agent [--environment-root PATH] --agent NAME --directory PATH --prompt TEXT' >&2
      exit "''${1:-2}"
    }

    while (($# > 0)); do
      case "$1" in
        --agent)
          (($# >= 2)) || usage
          agent="$2"
          shift 2
          ;;
        --directory|--dir)
          (($# >= 2)) || usage
          directory="$2"
          shift 2
          ;;
        --prompt)
          (($# >= 2)) || usage
          prompt="$2"
          shift 2
          ;;
        --environment-root|--env-root)
          (($# >= 2)) || usage
          environment_root="$2"
          shift 2
          ;;
        --help|-h)
          usage 0
          ;;
        *)
          printf 'error: unknown argument: %s\n' "$1" >&2
          usage
          ;;
      esac
    done

    [[ "$agent" =~ ^[a-z0-9][a-z0-9-]*$ ]] || {
      printf '%s\n' 'error: --agent must be a generated agent name' >&2
      exit 2
    }
    [[ -d "$directory" ]] || {
      printf 'error: --directory is not an existing directory: %s\n' "$directory" >&2
      exit 2
    }
    [[ -d "$environment_root" ]] || {
      printf 'error: environment root is not an existing directory: %s\n' "$environment_root" >&2
      exit 2
    }
    [[ -n "$prompt" ]] || {
      printf '%s\n' 'error: --prompt must not be empty' >&2
      exit 2
    }

    config="$environment_root/$agent.json"
    [[ -f "$config" ]] || {
      printf 'error: no generated environment exists for agent: %s\n' "$agent" >&2
      exit 2
    }
    command -v opencode >/dev/null 2>&1 || {
      printf '%s\n' 'error: OpenCode executable is not available on PATH' >&2
      exit 2
    }

    export OPENCODE_CONFIG="$config"
    exec opencode run \
      --dir "$directory" \
      --agent "$agent" \
      "$prompt"
  '';
  meta = {
    description = "Run a generated OpenCode agent directly from the flake";
    mainProgram = "opencode-agent";
    platforms = lib.platforms.unix;
  };
}

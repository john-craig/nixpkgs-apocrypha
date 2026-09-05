{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.evak.opencode-agents;
  json = pkgs.formats.json {};
  nameType = lib.types.strMatching "[a-z0-9][a-z0-9-]*";
  actionType = lib.types.enum [
    "allow"
    "ask"
    "deny"
  ];
  permissionType = lib.types.attrsOf (lib.types.either actionType (lib.types.attrsOf actionType));

  mcpType = lib.types.submodule (
    {...}: {
      options = {
        type = lib.mkOption {
          type = lib.types.enum [
            "local"
            "remote"
          ];
          default = "local";
        };
        command = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        url = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Arguments for a local MCP command.";
        };
        enabled = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        timeout = lib.mkOption {
          type = lib.types.ints.positive;
          default = 30000;
          description = "Milliseconds allowed for MCP tool discovery, including package startup and remote connection setup.";
        };
        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
        };
        headers = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
        };
      };
    }
  );

  roleType = lib.types.submodule (
    {...}: {
      options = {
        description = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        prompt = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
        model = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        mode = lib.mkOption {
          type = lib.types.enum [
            "primary"
            "subagent"
            "all"
          ];
          default = "primary";
        };
        skills = lib.mkOption {
          type = lib.types.listOf nameType;
          default = [];
        };
        rules = lib.mkOption {
          type = lib.types.listOf nameType;
          default = [];
        };
        subagents = lib.mkOption {
          type = lib.types.listOf nameType;
          default = [];
        };
        mcp = lib.mkOption {
          type = lib.types.attrsOf mcpType;
          default = {};
        };
        permission = lib.mkOption {
          type = permissionType;
          default = {
            "*" = "ask";
          };
        };
        authentication = {
          mode = lib.mkOption {
            type = lib.types.enum [
              "shared"
              "file"
              "api-key"
              "none"
            ];
            default = "shared";
          };
          source = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
        projectDiscovery = lib.mkOption {
          type = lib.types.enum [
            "project-aware"
            "environment-only"
          ];
          default = "project-aware";
        };
      };
    }
  );

  selected = names: definitions:
    lib.genAttrs names (
      name:
        if lib.hasAttr name definitions
        then definitions.${name}
        else throw "evak.opencode-agents: unknown shared definition `${name}`"
    );

  mcpPermission = role: role.permission.mcp or role.permission."*" or "ask";
  mcpPermissions = role: lib.mapAttrs' (server: _: lib.nameValuePair "${server}_*" (mcpPermission role)) role.mcp;

  roleConfig = name: role: {
    description = role.description;
    mode = role.mode;
    prompt = "{file:${promptFiles.${name}}}";
    model = role.model;
    permission = role.permission // mcpPermissions role;
    tools = lib.mapAttrs' (server: _: lib.nameValuePair "${server}_*" true) role.mcp;
  };

  subagentConfig = profile: {
    mode = "subagent";
    description = profile.description or "Reusable OpenCode subagent.";
    prompt = profile.prompt or "Perform the delegated task within the supplied scope.";
    permission =
      profile.permission or {
        "*" = "deny";
        read = "allow";
        list = "allow";
      };
  };

  mcpConfig = server: {
    type = server.type;
    command =
      if server.type == "local"
      then server.command ++ server.args
      else null;
    url = server.url;
    enabled = server.enabled;
    timeout = server.timeout;
    environment = server.environment;
    headers = server.headers;
  };

  promptFiles =
    lib.mapAttrs (
      name: role: pkgs.writeText "opencode-agent-${name}.md" role.prompt
    )
    cfg.agents;
  roleConfigFile = name: role:
    json.generate "opencode-agent-${name}.json" {
      "$schema" = "https://opencode.ai/config.json";
      default_agent = name;
      agent =
        {
          ${name} = roleConfig name role;
        }
        // lib.mapAttrs (_: subagentConfig) (selected role.subagents cfg.subagents);
      permission =
        cfg.permissions
        // role.permission
        // mcpPermissions role;
      tools = lib.mapAttrs' (server: _: lib.nameValuePair "${server}_*" true) role.mcp;
      mcp = lib.mapAttrs (_: mcpConfig) role.mcp;
    };
  roleFiles =
    lib.mapAttrs' (
      name: role:
        lib.nameValuePair ".config/opencode/environments/${name}.json" {
          source = roleConfigFile name role;
        }
    )
    cfg.agents;
  roleContent =
    lib.mapAttrsToList (
      agentName: role:
        (lib.mapAttrsToList (
          skill: text:
            lib.nameValuePair ".config/opencode/environments/${agentName}/skills/${skill}/SKILL.md" {
              inherit text;
            }
        ) (selected role.skills cfg.skills))
        ++ (lib.mapAttrsToList (
          rule: text:
            lib.nameValuePair ".config/opencode/environments/${agentName}/rules/${rule}.md" {inherit text;}
        ) (selected role.rules cfg.rules))
        ++ [
          {
            name = ".config/opencode/environments/${agentName}/prompt.md";
            value.source = promptFiles.${agentName};
          }
        ]
    )
    cfg.agents;
  defaultFile = lib.optionalAttrs (cfg.defaultAgent != null) {
    ".config/opencode/opencode-agents.json".source =
      roleConfigFile cfg.defaultAgent
      cfg.agents.${cfg.defaultAgent};
  };
  runner = pkgs.writeShellApplication {
    name = "opencode-agent";
    runtimeInputs = [pkgs.bash pkgs.coreutils];
    text = ''
      set -euo pipefail

      agent=""
      directory=""
      prompt=""
      prompt_set=0
      interactive=0

      usage() {
        printf 'Usage: opencode-agent --agent NAME --directory PATH (--prompt TEXT | --interactive)\n' >&2
        exit 2
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
            prompt_set=1
            shift 2
            ;;
          --interactive)
            interactive=1
            shift
            ;;
          --help|-h)
            usage
            ;;
          *)
            printf 'error: unknown argument: %s\n' "$1" >&2
            usage
            ;;
        esac
      done

      [[ "$agent" =~ ^[a-z0-9][a-z0-9-]*$ ]] || {
        printf 'error: --agent must be a generated agent name\n' >&2
        exit 2
      }
      [[ -d "$directory" ]] || {
        printf 'error: --directory is not an existing directory: %s\n' "$directory" >&2
        exit 2
      }
      if ((interactive && prompt_set)); then
        printf 'error: --interactive cannot be combined with --prompt\n' >&2
        exit 2
      fi
      if ((! interactive)) && [[ -z "$prompt" ]]; then
        printf 'error: --prompt must not be empty\n' >&2
        exit 2
      fi

      config="$HOME/.config/opencode/environments/$agent.json"
      [[ -f "$config" ]] || {
        printf 'error: no generated environment exists for agent: %s\n' "$agent" >&2
        exit 2
      }

      export OPENCODE_CONFIG="$config"
      isolated_config_home="$(mktemp -d)"
      trap 'rm -rf "$isolated_config_home"' EXIT
      export XDG_CONFIG_HOME="$isolated_config_home"
      unset OPENCODE_CONFIG_DIR OPENCODE_CONFIG_CONTENT OPENCODE_PORT OPENCODE_HOST
      set +e
      if ((interactive)); then
        ${cfg.opencodePackage}/bin/opencode --agent "$agent" "$directory"
      else
        ${cfg.opencodePackage}/bin/opencode run \
            --dir "$directory" \
            --agent "$agent" \
            "$prompt"
      fi
      status=$?
      set -e
      exit "$status"
    '';
  };
in {
  imports = [./definitions.nix];
  options.evak.opencode-agents = {
    enable = lib.mkEnableOption "declarative OpenCode agent environments";
    opencodePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default =
        if pkgs ? opencode
        then pkgs.opencode
        else null;
      description = "OpenCode package used by the opencode-agent runner.";
    };
    defaultAgent = lib.mkOption {
      type = lib.types.nullOr nameType;
      default = null;
      description = "Default primary OpenCode agent.";
    };
    permissions = lib.mkOption {
      type = permissionType;
      default = {
        "*" = "ask";
      };
    };
    skills = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = {};
    };
    rules = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = {};
    };
    subagents = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
    };
    agents = lib.mkOption {
      type = lib.types.attrsOf roleType;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      [
        {
          assertion = cfg.opencodePackage != null;
          message = "evak.opencode-agents requires an OpenCode package for the runner; set evak.opencode-agents.opencodePackage.";
        }
      ]
      ++ [
        {
          assertion = cfg.defaultAgent == null || lib.hasAttr cfg.defaultAgent cfg.agents;
          message = "evak.opencode-agents.defaultAgent must name a configured agent.";
        }
      ]
      ++ lib.flatten (
        lib.mapAttrsToList (name: role: [
          {
            assertion =
              role.authentication.mode
              == "shared"
              || role.authentication.mode == "none"
              || role.authentication.source != null;
            message = "evak.opencode-agents agent `${name}` requires authentication.source for mode `${role.authentication.mode}`.";
          }
          {
            assertion = lib.all (skill: lib.hasAttr skill cfg.skills) role.skills;
            message = "evak.opencode-agents agent `${name}` selects an unknown skill.";
          }
          {
            assertion = lib.all (rule: lib.hasAttr rule cfg.rules) role.rules;
            message = "evak.opencode-agents agent `${name}` selects an unknown rule.";
          }
          {
            assertion = lib.all (subagent: lib.hasAttr subagent cfg.subagents) role.subagents;
            message = "evak.opencode-agents agent `${name}` selects an unknown subagent.";
          }
        ])
        cfg.agents
      );

    home.file = lib.listToAttrs (lib.concatLists roleContent) // roleFiles // defaultFile;
    home.packages = [runner];
  };
}

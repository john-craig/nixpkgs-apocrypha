{ pkgs }:
let
  eval =
    enable: extra:
    pkgs.lib.evalModules {
      specialArgs = { inherit pkgs; };
      modules = [
        ({ lib, ... }: {
          options.assertions = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options.assertion = lib.mkOption { type = lib.types.bool; };
                options.message = lib.mkOption { type = lib.types.str; };
              }
            );
            default = [ ];
          };
          options.home.file = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
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
              }
            );
            default = { };
          };
          config.evak.opencode-agents.enable = enable;
          config.evak.opencode.enable = enable;
        })
        ./../home-modules/opencode
        ./../home-modules/opencode-agents
        extra
      ];
    };
  enabled = (eval true { }).config.home.file;
  disabled = (eval false { }).config.home.file;
  invalidAuth =
    (eval true {
      config.evak.opencode-agents.agents.invalid-auth.authentication = {
        mode = "file";
      };
    }).config;
  config = enabled.".config/opencode/opencode-agents.json".source;
  remoteSkill =
    enabled.".config/opencode/environments/remote-systems-diagnostics-assistant/skills/remote-diagnostics/SKILL.md".text;
  touchdesignerSkill =
    enabled.".config/opencode/environments/audiovisual-design-assistant/skills/touchdesigner/SKILL.md".text;
in
assert disabled == { };
assert builtins.length (builtins.attrNames enabled) >= 16;
assert builtins.all (item: item.assertion) (eval true { }).config.assertions;
assert builtins.any (item: !item.assertion) invalidAuth.assertions;
assert builtins.match ".*host identity.*" remoteSkill != null;
assert builtins.match ".*TouchDesigner.*" touchdesignerSkill != null;
pkgs.runCommand "opencode-agents-test" { nativeBuildInputs = [ pkgs.jq ]; } ''
  jq -e '."$schema" == "https://opencode.ai/config.json" and .default_agent == "orchestrator" and .agent.orchestrator.model == "openai/gpt-5.6-sol" and .agent.requirements.mode == "subagent" and .mcp.remcodex.headers.Authorization == "Bearer {env:REMCODEX_MCP_API_TOKEN}"' ${config} >/dev/null
  jq -e '(.mcp // {}) == {}' ${
    enabled.".config/opencode/environments/developer.json".source
  } >/dev/null
  jq -e '.mcp.jellyfin.environment.JELLYFIN_API_KEY == "{env:JELLYFIN_API_KEY}" and .mcp.digarr.enabled == true' ${
    enabled.".config/opencode/environments/disk-jockey.json".source
  } >/dev/null
  test ${builtins.toString (builtins.length (builtins.attrNames enabled))} -ge 16
  ! grep -q 'super-secret' ${config}
  touch $out
''

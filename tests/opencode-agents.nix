{pkgs}: let
  eval = enable: extra:
    pkgs.lib.evalModules {
      specialArgs = {inherit pkgs;};
      modules = [
        ({lib, ...}: {
          options.assertions = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options.assertion = lib.mkOption {type = lib.types.bool;};
                options.message = lib.mkOption {type = lib.types.str;};
              }
            );
            default = [];
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
            default = {};
          };
          options.home.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
          };
          config.evak.opencode-agents.enable = enable;
          config.evak.opencode.enable = enable;
        })
        ./../home-modules/opencode
        ./../home-modules/opencode-agents
        extra
      ];
    };
  enabled = (eval true {}).config.home.file;
  enabledPackages = (eval true {}).config.home.packages;
  disabled = (eval false {}).config.home.file;
  disabledPackages = (eval false {}).config.home.packages;
  invalidAuth =
    (eval true {
      config.evak.opencode-agents.agents.invalid-auth.authentication = {
        mode = "file";
      };
    }).config;
  config = enabled.".config/opencode/opencode-agents.json".source;
  architectConfig = enabled.".config/opencode/environments/software-architect.json".source;
  developerConfig = enabled.".config/opencode/environments/developer.json".source;
  restrictedDeveloperConfig =
    (eval true {
      config.evak.opencode-agents.agents.developer.permission = {
        "*" = "deny";
        read = "allow";
        list = "allow";
      };
    }).config.home.file.".config/opencode/environments/developer.json".source;
  runner = builtins.head enabledPackages;
  fakeOpenCode = pkgs.writeShellScriptBin "opencode" ''
    printf '%s' "$OPENCODE_CONFIG" > "$HOME/config-path"
    index=0
    for argument in "$@"; do
      printf '%s' "$argument" > "$HOME/invocation-$index"
      index=$((index + 1))
    done
    exit 7
  '';
  runnerEval = eval true {
    config.evak.opencode-agents.opencodePackage = fakeOpenCode;
  };
  runnerWithFake = builtins.head runnerEval.config.home.packages;
  remoteSkill =
    enabled.".config/opencode/environments/remote-systems-diagnostics-assistant/skills/remote-diagnostics/SKILL.md".text;
  touchdesignerSkill =
    enabled.".config/opencode/environments/audiovisual-design-assistant/skills/touchdesigner/SKILL.md".text;
in
  assert disabled == {};
  assert disabledPackages == [];
  assert builtins.length (builtins.attrNames enabled) >= 16;
  assert builtins.length enabledPackages == 1;
  assert builtins.all (item: item.assertion) (eval true {}).config.assertions;
  assert builtins.any (item: !item.assertion) invalidAuth.assertions;
  assert builtins.match ".*host identity.*" remoteSkill != null;
  assert builtins.match ".*TouchDesigner.*" touchdesignerSkill != null;
    pkgs.runCommand "opencode-agents-test" {nativeBuildInputs = [pkgs.jq];} ''
          jq -e '."$schema" == "https://opencode.ai/config.json" and .default_agent == "orchestrator" and .agent.orchestrator.model == "openai/gpt-5.6-sol" and .agent.requirements.mode == "subagent" and .mcp.remcodex.headers.Authorization == "Bearer {env:REMCODEX_MCP_API_TOKEN}"' ${config} >/dev/null
          jq -e '(.mcp // {}) == {}' ${
        enabled.".config/opencode/environments/developer.json".source
      } >/dev/null
          jq -e '.mcp.jellyfin.environment.JELLYFIN_API_KEY == "{env:JELLYFIN_API_KEY}" and .mcp.digarr.enabled == true' ${
        enabled.".config/opencode/environments/disk-jockey.json".source
      } >/dev/null
          jq -e '.agent["software-architect"].model == "openai/gpt-5.6-sol" and .agent["software-architect"].permission.edit == "deny" and .agent["software-architect"].permission.bash == "deny"' ${architectConfig} >/dev/null
          jq -e '.agent.developer.permission["*"] == "allow"' ${developerConfig} >/dev/null
          jq -e '.agent.developer.permission["*"] == "deny" and .agent.developer.permission.read == "allow"' ${restrictedDeveloperConfig} >/dev/null
          test -x ${runner}/bin/opencode-agent

          home=$(mktemp -d)
          mkdir -p "$home/project" "$home/.config/opencode/environments"
          touch "$home/.config/opencode/environments/developer.json"
          prompt=$'Preserve "quoted" text\nand whitespace.'
          set +e
          HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent developer --directory "$home/project" --prompt "$prompt"
          status=$?
          set -e
          test "$status" -eq 7
          test "$(cat "$home/invocation-0")" = run
          test "$(cat "$home/invocation-1")" = --dir
          test "$(cat "$home/invocation-2")" = "$home/project"
          test "$(cat "$home/invocation-3")" = --agent
      test "$(cat "$home/invocation-4")" = developer
      printf '%s' "$prompt" | cmp - "$home/invocation-5"
      test ! -e "$home/invocation-6"
      test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/developer.json"
          rm "$home"/invocation-*
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent unknown --directory "$home/project" --prompt test 2>/dev/null
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent developer --directory "$home/missing" --prompt test 2>/dev/null
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent developer --directory "$home/project" --prompt "" 2>/dev/null
          test ! -e "$home/invocation-0"
          test ${builtins.toString (builtins.length (builtins.attrNames enabled))} -ge 16
          ! grep -q 'super-secret' ${config}
          touch $out
    ''

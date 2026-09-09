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
  deploymentConfig = enabled.".config/opencode/environments/deployment-specialist.json".source;
  godotConfig = enabled.".config/opencode/environments/godot-game-developer.json".source;
  videoEditingConfig = enabled.".config/opencode/environments/video-editing-assistant.json".source;
  podcastWriterConfig = enabled.".config/opencode/environments/podcast-writer.json".source;
  researchCollectorConfig = enabled.".config/opencode/environments/research-source-collector.json".source;
  marketResearchConfig = enabled.".config/opencode/environments/market-researcher.json".source;
  marketResearchSkill =
    enabled.".config/opencode/environments/market-researcher/skills/market-research/SKILL.md".text;
  readOnlyMarketResearchConfig =
    (eval true {
      config.evak.opencode-agents.agents.market-researcher.permission = {
        "*" = "deny";
        read = "allow";
        list = "allow";
        mcp = "ask";
      };
    }).config.home.file.".config/opencode/environments/market-researcher.json".source;
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
    printf '%s' "''${1-}" > "$HOME/launch-option"
    printf '%s' "$OPENCODE_CONFIG" > "$HOME/config-path"
    printf '%s' "''${OPENCODE_CONFIG_DIR-}" > "$HOME/config-dir"
    printf '%s' "$XDG_CONFIG_HOME" > "$HOME/xdg-config-home"
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
  expectedAgents = [
    "default"
    "developer"
    "deployment-specialist"
    "software-architect"
    "orchestrator"
    "audiovisual-design-assistant"
    "godot-game-developer"
    "video-editing-assistant"
    "podcast-writer"
    "research-source-collector"
    "disk-jockey"
    "librarian"
    "market-researcher"
    "note-taker"
    "project-manager"
    "remote-systems-diagnostics-assistant"
    "researcher"
    "retrospective"
   "systems-architect"
   "toolsmith"
   "voice-assistant"
  ];
  mcpAgents = [
    "orchestrator"
    "audiovisual-design-assistant"
    "godot-game-developer"
    "research-source-collector"
    "disk-jockey"
    "librarian"
    "market-researcher"
    "note-taker"
    "project-manager"
    "remote-systems-diagnostics-assistant"
    "researcher"
    "systems-architect"
    "voice-assistant"
    "video-editing-assistant"
  ];
  mcpConfigs = map (name: enabled.".config/opencode/environments/${name}.json".source) mcpAgents;
  generatedAgentPaths = map (name: ".config/opencode/environments/${name}.json") expectedAgents;
  remoteSkill =
    enabled.".config/opencode/environments/remote-systems-diagnostics-assistant/skills/remote-diagnostics/SKILL.md".text;
  touchdesignerSkill =
    enabled.".config/opencode/environments/audiovisual-design-assistant/skills/touchdesigner/SKILL.md".text;
  godotSkill =
    enabled.".config/opencode/environments/godot-game-developer/skills/godot-development/SKILL.md".text;
  videoEditingSkill =
    enabled.".config/opencode/environments/video-editing-assistant/skills/video-editing/SKILL.md".text;
  podcastSkill =
    enabled.".config/opencode/environments/podcast-writer/skills/podcast-writing/SKILL.md".text;
  researchCollectorSkill =
    enabled.".config/opencode/environments/research-source-collector/skills/research-source-collection/SKILL.md".text;
 in
   assert disabled == {};
   assert disabledPackages == [];
  assert builtins.attrNames (eval true {}).config.evak.opencode-agents.agents == builtins.sort builtins.lessThan expectedAgents;
  assert builtins.length (builtins.attrNames enabled) >= 18;
  assert builtins.all (path: builtins.hasAttr path enabled) generatedAgentPaths;
  assert builtins.length enabledPackages == 1;
  assert builtins.all (item: item.assertion) (eval true {}).config.assertions;
  assert builtins.any (item: !item.assertion) invalidAuth.assertions;
  assert builtins.match ".*host identity.*" remoteSkill != null;
  assert builtins.match ".*TouchDesigner.*" touchdesignerSkill != null;
  assert builtins.match ".*2D.*" godotSkill != null;
  assert builtins.match ".*3D.*" godotSkill != null;
  assert builtins.match ".*scene architecture.*" godotSkill != null;
  assert builtins.match ".*GDScript.*" godotSkill != null;
  assert builtins.match ".*TileMap.*" godotSkill != null;
  assert builtins.match ".*navigation.*" godotSkill != null;
  assert builtins.match ".*performance.*" godotSkill != null;
  assert builtins.match ".*untrusted.*" godotSkill != null;
  assert builtins.match ".*provenance.*" godotSkill != null;
  assert builtins.match ".*approval.*" godotSkill != null;
  assert builtins.match ".*HyperFrames.*" videoEditingSkill != null;
  assert builtins.match ".*OpenMontage.*" videoEditingSkill != null;
  assert builtins.match ".*Kdenlive.*" videoEditingSkill != null;
  assert builtins.match ".*snapshot.*" videoEditingSkill != null;
  assert builtins.match ".*timeline.*approval.*" videoEditingSkill != null;
  assert builtins.match ".*render.*" videoEditingSkill != null;
  assert builtins.match ".*export.*" videoEditingSkill != null;
  assert builtins.match ".*unavailable.*" videoEditingSkill != null;
  assert builtins.match ".*provenance.*" videoEditingSkill != null;
  assert builtins.match ".*multi.*segment.*" podcastSkill != null;
  assert builtins.match ".*speaker.*turn.*" podcastSkill != null;
  assert builtins.match ".*citation.*" podcastSkill != null;
  assert builtins.match ".*uncertainty.*" podcastSkill != null;
  assert builtins.match ".*untrusted.*" podcastSkill != null;
  assert builtins.match ".*browse.*" podcastSkill != null;
  assert builtins.match ".*synthesi.*" podcastSkill != null;
  assert builtins.match ".*recent.*" researchCollectorSkill != null;
  assert builtins.match ".*historical.*" researchCollectorSkill != null;
  assert builtins.match ".*[Cc]anonical.*" researchCollectorSkill != null;
  assert builtins.match ".*deduplicate.*" researchCollectorSkill != null;
  assert builtins.match ".*hash.*" researchCollectorSkill != null;
  assert builtins.match ".*contradictions.*" researchCollectorSkill != null;
  assert builtins.match ".*non-operational.*" researchCollectorSkill != null;
  assert builtins.match ".*memory.*" researchCollectorSkill != null;
  assert builtins.match ".*fabricate.*" researchCollectorSkill != null;
  assert builtins.match ".*evidence-ledger.*" marketResearchSkill != null;
  assert builtins.match ".*explicitly identified local output.*" marketResearchSkill != null;
  assert builtins.match ".*superseded.*" marketResearchSkill != null;
  assert builtins.match ".*untrusted data.*" marketResearchSkill != null;
  assert builtins.match ".*credentials.*" marketResearchSkill != null;
  assert builtins.match ".*external services.*" marketResearchSkill != null;
  assert !builtins.hasAttr ".config/opencode/environments/podcast-writer/skills/research-source-collection/SKILL.md" enabled;
  assert !builtins.hasAttr ".config/opencode/environments/research-source-collector/skills/podcast-writing/SKILL.md" enabled;
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
          jq -e '.agent["deployment-specialist"].model == "openai/gpt-5.6-sol" and .agent["deployment-specialist"].permission.bash == "ask" and .agent["deployment-specialist"].permission.edit == "deny" and (.agent["deployment-specialist"].description | contains("alucard"))' ${deploymentConfig} >/dev/null
           jq -e '.agent["godot-game-developer"].model == "openai/gpt-5.6-sol" and .agent["godot-game-developer"].permission.edit == "allow" and .agent["godot-game-developer"].permission.bash == "ask" and .agent["godot-game-developer"].permission.mcp == "ask"' ${godotConfig} >/dev/null
           jq -e '.agent["godot-game-developer"].permission["godot_*"] == "ask"' ${godotConfig} >/dev/null
           jq -e '.mcp.godot.command == ["npx", "-y", "@npgamedev/godot-mcp-server"] and .mcp.godot.environment.GODOT_MCP_PROJECT_PATH == "{env:GODOT_MCP_PROJECT_PATH}" and .mcp.godot.environment.GODOT_MCP_READ_ONLY == "{env:GODOT_MCP_READ_ONLY}"' ${godotConfig} >/dev/null
           jq -e '.mcp.godot.timeout == 30000' ${godotConfig} >/dev/null
           jq -e '(.mcp | keys) == ["godot"]' ${godotConfig} >/dev/null
           jq -e '.agent["video-editing-assistant"].model == "openai/gpt-5.6-sol" and .agent["video-editing-assistant"].permission.edit == "ask" and .agent["video-editing-assistant"].permission.bash == "ask" and .agent["video-editing-assistant"].permission.mcp == "ask" and .agent["video-editing-assistant"].permission.task == "deny"' ${videoEditingConfig} >/dev/null
           jq -e '.mcp.kdenlive.command == ["python", "-m", "mcp_kdenlive"] and (.mcp | keys) == ["kdenlive"] and (.mcp.kdenlive.environment // {}) == {} and (.mcp.kdenlive.headers // {}) == {}' ${videoEditingConfig} >/dev/null
          jq -e '.agent["podcast-writer"].model == "openai/gpt-5.6-luna" and .agent["podcast-writer"].permission.edit == "allow" and .agent["podcast-writer"].permission.websearch == "deny" and .agent["podcast-writer"].permission.bash == "deny" and (.mcp // {}) == {}' ${podcastWriterConfig} >/dev/null
            jq -e '.agent["research-source-collector"].model == "openai/gpt-5.6-luna" and .agent["research-source-collector"].permission.websearch == "allow" and .agent["research-source-collector"].permission.webfetch == "allow" and .agent["research-source-collector"].permission.bash == "deny" and (.mcp | keys) == ["opensearch", "read_website_fast"]' ${researchCollectorConfig} >/dev/null
            jq -e '.agent["market-researcher"].model == "openai/gpt-5.6-terra" and .agent["market-researcher"].permission.edit == "allow" and .agent["market-researcher"].permission.read == "allow" and .agent["market-researcher"].permission.bash == "ask" and .agent["market-researcher"].permission.websearch == "deny" and .agent["market-researcher"].permission.webfetch == "deny" and .agent["market-researcher"].permission.mcp == "ask" and .agent["market-researcher"].permission["open_websearch_*"] == "ask" and .agent["market-researcher"].permission["read_website_fast_*"] == "ask"' ${marketResearchConfig} >/dev/null
            jq -e '.mcp.open_websearch.command == ["npx", "-y", "open-websearch@latest"] and .mcp.read_website_fast.command == ["npx", "-y", "@just-every/mcp-read-website-fast"] and ([.mcp[] | has("environment") and (to_entries | all(.[]; (.value | tostring | test("secret|token|private|/home/|/tmp/"; "i") | not)))] | all)' ${marketResearchConfig} >/dev/null
            jq -e '.agent["market-researcher"].permission["*"] == "deny" and .agent["market-researcher"].permission.edit == "allow" and .agent["market-researcher"].permission.bash == "ask"' ${readOnlyMarketResearchConfig} >/dev/null
           jq -e '.mcp.opensearch.environment.MODE == "stdio"' ${researchCollectorConfig} >/dev/null
           jq -e '.agent["research-source-collector"].tools["opensearch_*"] == true and .agent["research-source-collector"].tools["read_website_fast_*"] == true' ${researchCollectorConfig} >/dev/null
            jq -e '.agent["research-source-collector"].permission["opensearch_*"] == "allow" and .agent["research-source-collector"].permission["read_website_fast_*"] == "allow"' ${researchCollectorConfig} >/dev/null
            jq -e '.mcp.opensearch.command == ["npx", "-y", "open-websearch@latest"] and .mcp.read_website_fast.command == ["npx", "-y", "@just-every/mcp-read-website-fast"]' ${researchCollectorConfig} >/dev/null
            jq -e 'all(.mcp[]; .timeout == 30000)' ${researchCollectorConfig} >/dev/null
           jq -e '.agent["orchestrator"].permission.mcp == "ask" and .agent["orchestrator"].permission["remcodex_*"] == "ask" and .agent["orchestrator"].permission["seshat_*"] == "ask"' ${config} >/dev/null
           jq -e '.mcp.remcodex.url == "http://127.0.0.1:18840/mcp" and .mcp.context7 == null' ${config} >/dev/null
           for mcp_config in ${builtins.concatStringsSep " " mcpConfigs}; do
             jq -e 'all(.mcp[]; .timeout == 30000)' "$mcp_config" >/dev/null
           done
          jq -e '.agent.developer.permission["*"] == "deny" and .agent.developer.permission.read == "allow"' ${restrictedDeveloperConfig} >/dev/null
          test -x ${runner}/bin/opencode-agent

          home=$(mktemp -d)
          mkdir -p "$home/project" "$home/.config/opencode/environments"
          touch "$home/.config/opencode/environments/developer.json"
          touch "$home/.config/opencode/environments/godot-game-developer.json"
          touch "$home/.config/opencode/environments/podcast-writer.json"
          touch "$home/.config/opencode/environments/research-source-collector.json"
          touch "$home/.config/opencode/environments/video-editing-assistant.json"
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
           test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/developer.json"
           test ! -s "$home/config-dir"
           test ! -e "$(cat "$home/xdg-config-home")"
          test ! -e "$home/invocation-6"
          rm "$home"/invocation-*
          set +e
          HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent developer --directory "$home/project" --interactive
          status=$?
          set -e
          test "$status" -eq 7
          test "$(cat "$home/invocation-0")" = --agent
          test "$(cat "$home/invocation-1")" = developer
          test "$(cat "$home/invocation-2")" = "$home/project"
          test ! -e "$home/invocation-3"
           test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/developer.json"
           test ! -s "$home/config-dir"
           test ! -e "$(cat "$home/xdg-config-home")"
          rm "$home"/invocation-*
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent developer --directory "$home/project" --interactive --prompt test 2>/dev/null
          test ! -e "$home/invocation-0"
           prompt=$'Inspect Godot project\nwithout implicit automation.'
          set +e
          HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent godot-game-developer --directory "$home/project" --prompt "$prompt"
          status=$?
          set -e
          test "$status" -eq 7
          test "$(cat "$home/invocation-1")" = --dir
          test "$(cat "$home/invocation-2")" = "$home/project"
          test "$(cat "$home/invocation-3")" = --agent
          test "$(cat "$home/invocation-4")" = godot-game-developer
          printf '%s' "$prompt" | cmp - "$home/invocation-5"
          test ! -e "$home/invocation-6"
          test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/godot-game-developer.json"
          prompt=$'Write only the cited episode JSON.'
          set +e
          HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent podcast-writer --directory "$home/project" --prompt "$prompt"
          status=$?
          set -e
          test "$status" -eq 7
          test "$(cat "$home/invocation-4")" = podcast-writer
          printf '%s' "$prompt" | cmp - "$home/invocation-5"
          test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/podcast-writer.json"
          prompt=$'Collect only approved public sources.'
          set +e
          HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent research-source-collector --directory "$home/project" --prompt "$prompt"
          status=$?
          set -e
          test "$status" -eq 7
          test "$(cat "$home/invocation-4")" = research-source-collector
          printf '%s' "$prompt" | cmp - "$home/invocation-5"
          test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/research-source-collector.json"
          rm "$home"/invocation-*
          prompt=$'Inspect footage and propose an approved edit plan.'
          set +e
          HOME="$home" ${runnerWithFake}/bin/opencode-agent \
            --agent video-editing-assistant --directory "$home/project" --prompt "$prompt"
          status=$?
          set -e
          test "$status" -eq 7
          test "$(cat "$home/invocation-4")" = video-editing-assistant
          printf '%s' "$prompt" | cmp - "$home/invocation-5"
          test "$(cat "$home/config-path")" = "$home/.config/opencode/environments/video-editing-assistant.json"
          rm "$home"/invocation-*
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent unknown --directory "$home/project" --prompt test 2>/dev/null
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent developer --directory "$home/missing" --prompt test 2>/dev/null
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent developer --directory "$home/project" --prompt "" 2>/dev/null
          ! HOME="$home" ${runnerWithFake}/bin/opencode-agent --agent developer --directory "$home/project" 2>/dev/null
          test ! -e "$home/invocation-0"
          test ${builtins.toString (builtins.length (builtins.attrNames enabled))} -ge 26
          grep -F '${pkgs.opencode}/bin/opencode' '${runner}/bin/opencode-agent'
          ! grep -q 'super-secret' ${config}
          touch $out
    ''

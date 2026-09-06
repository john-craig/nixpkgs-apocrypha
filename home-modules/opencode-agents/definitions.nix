{lib, ...}: let
  shared = import ./shared {inherit lib;};
  agentSources = {
    default = ./agents/default;
    developer = ./agents/developer;
    deployment-specialist = ./agents/deployment-specialist;
    software-architect = ./agents/software-architect;
    orchestrator = ./agents/orchestrator;
    audiovisual-design-assistant = ./agents/audiovisual-design-assistant;
    godot-game-developer = ./agents/godot-game-developer;
    podcast-writer = ./agents/podcast-writer;
    research-source-collector = ./agents/research-source-collector;
    disk-jockey = ./agents/disk-jockey;
    blender-3d-modeler = ./agents/blender-3d-modeler;
    librarian = ./agents/librarian;
    market-researcher = ./agents/market-researcher;
    note-taker = ./agents/note-taker;
    project-manager = ./agents/project-manager;
    remote-systems-diagnostics-assistant = ./agents/remote-systems-diagnostics-assistant;
    researcher = ./agents/researcher;
    retrospective = ./agents/retrospective;
    systems-architect = ./agents/systems-architect;
    toolsmith = ./agents/toolsmith;
    voice-assistant = ./agents/voice-assistant;
  };
  agents = lib.mapAttrs (
    _: source:
      let
        entrypoint = import source;
      in entrypoint (lib.filterAttrs (name: _: builtins.hasAttr name (builtins.functionArgs entrypoint)) {
        inherit lib;
        inherit (shared) role prompt;
      })
  ) agentSources;
in {
  config.evak.opencode-agents = {
    defaultAgent = lib.mkDefault "orchestrator";
    inherit (shared) skills rules subagents;
    inherit agents;
  };
}

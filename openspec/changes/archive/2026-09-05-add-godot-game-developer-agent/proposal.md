## Why

Users need a repository-configured game-development specialist that can design and implement Godot games across both 2D and 3D workflows. The existing agents do not provide Godot-specific scene, resource, GDScript, gameplay, level-design, asset, runtime-validation, or export guidance, nor do they define safe boundaries for powerful editor and project automation tools.

## What Changes

- Add a `godot-game-developer` OpenCode agent for Godot project inspection, game design, implementation, debugging, testing, profiling, and approved project edits.
- Support 2D and 3D game design, including scene architecture, gameplay systems, UI, input, animation, physics, cameras, navigation, shaders, audio, levels, assets, and project/export configuration.
- Include selected open-source skill patterns from GodotPrompter, GD-Agentic-Skills, and awesome-gamedev-agent-skills without loading large conflicting catalogs or copying unlicensed material.
- Declare a local Godot MCP server, initially targeting `NPGameDev/godot-mcp-server` over stdio with its Godot editor addon and authenticated localhost bridge.
- Add runtime evidence and validation patterns for headless tests, scene inspection, screenshots, deterministic playtests, logs, and performance checks.
- Permit approved project-file edits while requiring approval for live-editor mutation, arbitrary script execution, project runs with external side effects, exports, destructive asset operations, and networked/device interactions.
- Add generated-configuration tests, flake coverage, documentation, version/prerequisite guidance, and credential/path isolation checks.

## Capabilities

### New Capabilities

- `godot-game-developer-agent`: Godot 2D/3D game design and implementation, project structure, gameplay systems, asset and level workflows, runtime validation, and safe MCP-assisted development.

### Modified Capabilities

- `opencode-agent-environments`: Add the named godot-game-developer environment with explicit Godot MCP configuration, project-edit permissions, and approval-gated runtime operations.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role, Godot development skill/rules, and local Godot MCP declaration.
- `tests/opencode-agents.nix` and `flake.nix` gain generated-role, MCP-isolation, permission, prompt, and runner coverage.
- `docs/opencode-agents.md` gains the role inventory, Godot/MCP prerequisites, project-root expectations, and runtime safety boundaries.
- Runtime consumers may need Godot 4.2+, Node.js 22+, the selected Godot MCP addon/server, and a local editor or headless Godot environment.
- No cloud game service, asset-generation provider, publishing credential, multiplayer deployment, or external write integration is required by the initial change.

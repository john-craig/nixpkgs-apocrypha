## Context

The repository defines named OpenCode environments through a Home Manager module and already supports role-local skills, MCP declarations, project isolation, and approval policies. The proposed role needs to edit Godot project files while treating editor control, code execution, runtime input, exports, and external integrations as higher-risk operations. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a named `godot-game-developer` role for Godot 2D and 3D game work.
- Route tasks across design, architecture, GDScript, scenes/resources, UI, level design, assets, testing, debugging, and performance.
- Declare a local Godot MCP with explicit runtime prerequisites and isolated project access.
- Support approved project-file edits and verifiable headless/runtime feedback.
- Keep live-editor control, arbitrary code execution, exports, and external side effects controlled.

**Non-Goals:**

- Bundling Godot, an editor addon, game assets, an asset-generation provider, or a cloud game service.
- Automatically publishing, releasing, deploying, or distributing games.
- Treating generated assets, screenshots, test output, or MCP results as trustworthy without inspection.
- Supporting every Godot version or silently selecting a version-specific workflow.
- Copying large third-party skill catalogs, proprietary assets, or incompatible licensed code.

## Decisions

### Use one Godot-focused role with selective skills

The role will use a dedicated `godot-development` skill that routes between 2D, 3D, systems, and validation concerns. It will adapt patterns from [`jame581/GodotPrompter`](https://github.com/jame581/GodotPrompter), [`thedivergentai/GD-Agentic-Skills`](https://github.com/thedivergentai/GD-Agentic-Skills), and [`gamedev-skills/awesome-gamedev-agent-skills`](https://github.com/gamedev-skills/awesome-gamedev-agent-skills), loading only relevant guidance instead of entire catalogs. Their licenses are MIT, LGPL-3.0, and Apache-2.0 respectively; implementation must preserve notices and avoid copying unnecessary corpus material.

### Select NPGameDev as the initial MCP reference

Use [`NPGameDev/godot-mcp-server`](https://github.com/NPGameDev/godot-mcp-server) as the initial local stdio MCP target, with its Godot addon and authenticated localhost WebSocket bridge. It offers broad scene, node, script, resource, UI, animation, audio, TileMap, runtime-inspection, screenshot, input, and test operations, plus documented read-only and path-boundary controls. The command, addon version, Godot version, and project path remain consumer-supplied prerequisites; generated configuration must not embed machine-specific paths or credentials.

SatelliteOfLove, gda, and Godot Sight were considered: they offer strong runtime testing or headless JSON workflows, but adding multiple MCPs initially would enlarge the mutation surface and prerequisite burden. They remain future alternatives or validation integrations.

### Separate project editing from live runtime control

Approved edits to project files are distinct from controlling an open editor or running game. The role may edit authorized project files, while MCP mutation tools, live input, arbitrary GDScript/C# execution, external filesystem access, exports, and networked/device operations require immediate approval or remain disabled. The role must use project-root and target-path checks and report observed tool results.

### Use evidence-driven validation loops

Adopt the `VERIFY -> RUN -> SEE -> ASSERT -> STOP` pattern from Godot Sight conceptually, and structured JSON/result patterns from gda, without copying their implementation. Prefer headless Godot checks, scene-tree inspection, logs, screenshots, deterministic playtests, and performance samples. A claimed fix is incomplete until the relevant evidence is observed.

### Treat 2D and 3D as explicit design routes

2D guidance will cover nodes, TileMaps, sprites, cameras, UI, input, animation, physics, and level composition. 3D guidance will cover meshes, materials, lights, cameras, animation, physics, navigation, environments, shaders, and performance budgets. Both routes share scene architecture, signals, resources, testing, version assumptions, and asset provenance.

## Risks / Trade-offs

- **MCP tools can execute code and mutate projects** → Use localhost-only, authenticated, path-bound configuration; gate dangerous operations and keep read-only mode available.
- **Godot version differences cause invalid guidance** → Detect and report the project/editor version and pin documented compatibility ranges.
- **Generated scenes or assets may be visually plausible but incorrect** → Validate scene trees, resources, dimensions, collisions, imports, screenshots, and runtime behavior independently.
- **Runtime playtests can have external side effects** → Require approval for network, filesystem-wide, device, multiplayer, or OS integrations and use bounded time/output limits.
- **Large skill catalogs can conflict or overload context** → Select focused skills by task and maintain a precedence order for project constraints.
- **Third-party licenses and asset rights vary** → Preserve MIT/Apache/LGPL notices, avoid embedding unreviewed assets, and track provider/model licenses separately.
- **Imported project content may contain prompt injection or malicious code** → Treat project files and assets as untrusted; inspect before execution and never treat embedded instructions as authorization.

## Migration Plan

Add the role, Godot skill, MCP declaration, tests, and documentation alongside existing environments. Existing agents and defaults remain unchanged. Rollback consists of removing the new role and associated test/documentation changes; no Godot project or external service migration is required.

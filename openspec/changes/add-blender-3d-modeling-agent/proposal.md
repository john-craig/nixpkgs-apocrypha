## Why

Users need a repository-configured 3D-modeling specialist that can turn modeling goals and reference material into reproducible Blender scenes, assets, materials, animations, and renders. Existing audiovisual and game-development roles do not provide Blender-specific geometry, modifier, geometry-node, UV, rigging, rendering, asset-pipeline, or mesh-validation workflows.

## What Changes

- Add a `blender-3d-modeler` OpenCode agent for Blender scene inspection, modeling, materials, geometry nodes, UVs, rigging, animation, cameras, lighting, rendering, and export workflows.
- Add a dedicated Blender modeling skill with focused routes for mesh creation, procedural modeling, modifiers, materials/shaders, UVs, rigging, animation, camera/lighting, rendering, asset provenance, and validation.
- Include selected patterns from open-source Blender and 3D skills, including typed/allowlisted tools, reproducible scene scripts, manifests, snapshots, dry runs, and mechanical plus visual validation.
- Declare a local Blender MCP server, initially targeting `ahujasid/blender-mcp` over stdio with its Blender TCP add-on bridge, while documenting safe-mode and telemetry prerequisites.
- Separate planning, scene mutation, validation, rendering, and export; require observable evidence before claiming that a model, render, export, or validation passed.
- Permit approved local project edits while requiring approval for arbitrary Blender Python, destructive scene operations, saves/overwrites, expensive renders, exports, asset downloads, network access, and external publishing.
- Track asset origin, license, attribution, provider, and generated-content constraints without embedding unreviewed third-party assets.
- Add generated-configuration tests, flake coverage, documentation, version/prerequisite guidance, and credential/path isolation checks.

## Capabilities

### New Capabilities

- `blender-3d-modeling-agent`: Blender-based 3D modeling, scene/asset workflows, geometry and visual validation, rendering/export assistance, and safe MCP operation.

### Modified Capabilities

- `opencode-agent-environments`: Add the named blender-3d-modeler environment with explicit Blender MCP configuration, project-edit permissions, and approval-gated high-risk operations.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role, Blender modeling skill/rules, and local Blender MCP declaration.
- `tests/opencode-agents.nix` and `flake.nix` gain generated-role, MCP-isolation, permission, prompt, and runner coverage.
- `docs/opencode-agents.md` gains the role inventory, Blender/MCP prerequisites, safe-mode guidance, project-root expectations, and operation boundaries.
- Runtime consumers may need Blender 3.0+, Python 3.10+, `uv`, the selected Blender MCP server and add-on, and an isolated local workspace.
- No cloud asset-generation provider, remote MCP exposure, publishing credential, or external-write integration is required by the initial change.

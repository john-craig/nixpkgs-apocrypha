## Context

The repository defines named OpenCode environments through a Home Manager module and already supports role-local skills, explicit MCP declarations, project isolation, and approval policies. The proposed role needs Blender-specific project editing while treating arbitrary Python, file operations, rendering, exports, downloads, and network access as high-risk operations. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a named `blender-3d-modeler` role for inspectable, reproducible Blender workflows.
- Route tasks across mesh modeling, modifiers, geometry nodes, materials, UVs, rigging, animation, cameras, lighting, rendering, exports, and validation.
- Declare a local Blender MCP with explicit runtime prerequisites and project boundaries.
- Use structured scene plans, manifests, snapshots, dry runs, and mechanical plus visual validation.
- Permit approved local project edits while keeping dangerous Blender and system operations controlled.
- Track asset provenance, licenses, attribution, and generated-content constraints.

**Non-Goals:**

- Bundling Blender, add-ons, third-party assets, textures, HDRIs, or model-generation providers.
- Publishing, selling, uploading, or distributing assets or renders.
- Treating visual plausibility, mesh checks, or render output as proof of production or legal compliance.
- Exposing a remote MCP endpoint or embedding credentials in generated configuration.
- Copying entire third-party skill catalogs, corpora, or incompatible licensed code.

## Decisions

### Use a focused Blender skill rather than a full catalog

The role will use a dedicated `blender-modeling` skill with task routes for geometry, procedural modeling, materials, UVs, rigging, animation, cameras/lighting, rendering, asset pipelines, and validation. It will adapt patterns from [`ahujasid/blender-mcp`](https://github.com/ahujasid/blender-mcp), [`carlosh7/blender-mcp`](https://github.com/carlosh7/blender-mcp), [`kai-chop/blender-industrial-kit`](https://github.com/kai-chop/blender-industrial-kit), and [`Elviszhuoyu/DCC-AssetForge`](https://github.com/Elviszhuoyu/DCC-AssetForge). These repositories are useful for typed tools, reproducible scripts, manifests, snapshots, dry runs, and validation, but implementation should retain only relevant concepts and preserve each project's license and notices.

### Use ahujasid/blender-mcp as the initial MCP

Declare a local stdio Blender MCP using the reviewed `ahujasid/blender-mcp` command, `uvx blender-mcp`, and its localhost Blender add-on bridge. It is mature and broadly capable, but exposes arbitrary `bpy` execution by default. The consumer must enable its safe mode where appropriate, disable telemetry when policy requires it, bind the bridge to localhost, and provide Blender/uv/add-on prerequisites. Generated configuration must not embed local paths, credentials, or claim runtime availability without evidence.

`blend-ai` and `blender-ai-mcp` were considered as safer or more verification-oriented alternatives. They remain viable replacements if the initial server's arbitrary-code surface or telemetry is unacceptable, but selecting among them is a separately reviewable implementation decision.

### Separate planning, mutation, validation, and export

The workflow will plan the scene and target changes first, use structured or reproducible operations where possible, validate geometry and assets, and only then render or export. Mutations, saves, overwrites, modifier application, baking, deletion, arbitrary Python, downloads, and exports require explicit approval immediately before execution. Source `.blend` files are backed up or copied before changes.

### Make manifests and evidence the source of truth

Each substantial asset or export should have observable provenance, parameters, Blender/tool versions, ownership, license, validation results, and output paths. Mechanical checks cover naming, dimensions, topology, manifoldness, intersections, modifiers, UVs, materials, and export constraints; visual checks cover framing, appearance, missing objects, and unintended artifacts. Passing one class of check does not imply the other.

### Keep imported content untrusted

Blend files, scripts, scene names, asset metadata, downloaded models, textures, reference images, and embedded text can contain prompt injection or malicious behavior. The agent will inspect them as data, never treat embedded instructions as authorization, and avoid executing untrusted scripts or opening untrusted files in a privileged environment.

## Risks / Trade-offs

- **Arbitrary Blender Python can access the host** → Prefer semantic tools, enable safe mode, deny or approval-gate raw code, use least-privilege workspaces, and never expose the bridge remotely.
- **Blender operations can destroy or overwrite work** → Use snapshots/copies, dry runs, explicit target paths, approval gates, and diff-like artifact reports.
- **Large geometry, simulations, textures, and Cycles renders can exhaust resources** → Set bounded time/output/resource expectations and require confirmation for expensive operations.
- **Tool output can look successful while the scene is wrong** → Require structured inspection plus visual evidence and report remaining uncertainty.
- **Assets and providers have varied licenses** → Track source URL, creator, license, attribution, provider, and model terms per asset; do not copy unreviewed assets.
- **Telemetry or external asset services can leak project data** → Disable telemetry where required, keep network off by default, and require explicit review for downloads or provider integrations.
- **Blender version differences break scripts and add-ons** → Detect and report the project/Blender version and pin or document supported ranges.

## Migration Plan

Add the role, Blender skill, MCP declaration, tests, and documentation alongside existing environments. Existing roles and defaults remain unchanged. Rollback consists of removing the role and associated test/documentation changes; no Blender project or external account migration is required.

## Context

The repository defines named OpenCode environments through a Home Manager module and already has explicit MCP isolation, evidence, no-secrets, and TouchDesigner safety patterns. The proposed role needs a conservative CAD exception: it may inspect drawings and produce plans, but geometry mutations, file writes, saves, exports, and previews must remain explicitly controlled. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a named `interior-design-assistant` role with staged design workflow and evidence-aware recommendations.
- Use a canonical room model that distinguishes measured, user-provided, inferred, and proposed geometry.
- Declare a local `librecad` MCP backed by `thebossnow/aiblueprint-mcp` for DXF operations and LibreCAD previews.
- Provide furniture/layout reasoning, circulation checks, and floor-plan review without claiming professional certification.
- Offer feng-shui suggestions as optional cultural or preference-based guidance.
- Protect source drawings, personal room imagery, credentials, and unrelated project files.

**Non-Goals:**

- Replacing an architect, engineer, accessibility specialist, fire-safety reviewer, or permitting authority.
- Treating generated layouts, dimensions, renders, or jurisdiction checks as construction or code compliance.
- Live GUI control, video generation, rendering workflows beyond the declared DXF/preview tool, or audiovisual output.
- Embedding GPL feng-shui, Sweet Home 3D, LibreCAD, or BIM implementation code into this repository.
- Persisting personal room imagery, birth-date data, household profiles, or a furniture database.

## Decisions

### Use Roomsmith as the workflow reference

Adapt the MIT-licensed [`Rumeasiyan/roomsmith`](https://github.com/Rumeasiyan/roomsmith) workflow: intake, survey, strategy, authoring, critique, and reporting, with explicit handoffs and approval gates. Its narrow roles and canonical design artifacts are useful patterns, but the implementation will use the existing OpenCode role model rather than copying Claude-specific prompts or spawning a multi-agent graph.

### Use a canonical room model and deterministic checks

Represent walls, openings, fixed features, dimensions, furniture, orientations, layers, and coordinate units in one source-of-truth model. Validate bounds, collisions, opening overlaps, circulation, scale, and unit consistency independently of generative prose. Photo-derived or ambiguous measurements remain inferred until confirmed by the user.

### Declare a LibreCAD-oriented MCP, not unrestricted CAD control

Use `thebossnow/aiblueprint-mcp` as the initial `librecad` MCP integration. It provides stdio MCP access to DXF generation/manipulation and LibreCAD `dxf2png` previews, but it is not live LibreCAD GUI control. The generated role configuration will declare the consumer-resolved `aiblueprint-mcp` command and workspace prerequisites without embedding machine-specific paths or credentials. The implementation must pin or document a reviewed source/release rather than silently depending on `latest`.

### Separate inspection from mutation

Read-only inspection and preview generation may be available when the MCP is operational. Creating, transforming, trimming, deleting, changing layers/units, saving, overwriting, exporting, converting, or printing CAD files requires explicit approval immediately before the operation. Source DXF files are preserved and generated output goes to a separate isolated workspace.

### Treat feng shui as optional cultural guidance

Adapt the conceptual rule categories from [`LeoOjutkangas/Feng-Shui-simulator`](https://github.com/LeoOjutkangas/Feng-Shui-simulator), whose implementation is GPL-3.0, only as independently authored or separately isolated rules. Feng-shui output must be labeled traditional, cultural, or preference-based, not scientifically validated causal advice. It must never override accessibility, safety, building code, budget, or user preferences. Kua or birth-date inputs are sensitive and are unnecessary unless the user explicitly requests that style of guidance.

### Keep imported files and imagery untrusted

DXF files, images, webpages, furniture catalogs, and embedded text may contain prompt-injection content or sensitive information. The role will treat them as data, minimize retention and external transmission, and never interpret embedded instructions as authorization.

## Risks / Trade-offs

- **Photo-derived dimensions are unreliable** → Label them inferred, request confirmation, and never call them construction-grade.
- **MCP geometry may be incomplete or wrong** → Preserve originals, validate independently, inspect generated previews, and report observed versus inferred results.
- **LibreCAD/aiblueprint runtime is immature or unavailable** → Fail closed, expose non-operational configuration honestly, document prerequisites, and provide text-only planning where possible.
- **CAD writes can damage source plans** → Use separate workspaces, explicit target paths, approval gates, and no automatic overwrite.
- **Feng-shui rules can be presented as science** → Label cultural status and subordinate them to safety, code, accessibility, and user choice.
- **Open-source assets have mixed licenses** → Do not copy GPL code or third-party furniture assets; retain notices for any reused MIT material and review component-level licensing.
- **Room imagery may contain personal data** → Ask for informed consent before external processing and avoid retaining or exposing unnecessary images or household details.

## Migration Plan

Add the role, interior-design skill, tests, MCP declaration, and documentation alongside existing environments. Existing roles and defaults remain unchanged. Rollback consists of removing the new role and associated test/documentation changes; no drawing migration or external service data migration is required.

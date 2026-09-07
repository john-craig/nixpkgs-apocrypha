## Why

Users need a repository-configured interior-design specialist that can turn room information and floor plans into practical layout and design proposals. The role should combine creative interior guidance with explicit geometry, privacy, safety, and cultural-context boundaries rather than treating generated renders or feng-shui rules as professional architectural advice.

## What Changes

- Add an `interior-design-assistant` OpenCode agent for room intake, layout planning, furniture placement, materials, lighting concepts, floor-plan review, and design reports.
- Add a staged workflow for intake, measurement/survey, design strategy, layout authoring, critique, and reporting.
- Add a LibreCAD-oriented `aiblueprint-mcp` declaration for DXF floor-plan generation, inspection, and previews, with runtime availability and workspace paths supplied by the consumer.
- Preserve a canonical distinction between measured, user-provided, inferred, and proposed geometry; never present photo-derived dimensions as construction-grade measurements.
- Include feng-shui guidance as optional cultural or preference-based recommendations that never override accessibility, safety, building code, or user requirements.
- Keep CAD edits, saves, overwrites, exports, conversions, and external outputs approval-gated; preserve source drawings and prefer separate working copies.
- Add generated-configuration tests, flake coverage, and documentation for the role, MCP prerequisites, limitations, and safety boundaries.

## Capabilities

### New Capabilities

- `interior-design-agent`: Evidence-aware interior planning, floor-plan interaction, layout validation, feng-shui preference guidance, and bounded CAD operations.

### Modified Capabilities

- `opencode-agent-environments`: Add the named interior-design-assistant environment with isolated interior-design guidance, explicit LibreCAD MCP configuration, and conservative CAD permissions.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role, interior-design skill, safety rules, and LibreCAD MCP declaration.
- `tests/opencode-agents.nix` and `flake.nix` gain generated-role, skill, MCP-isolation, and permission coverage.
- `docs/opencode-agents.md` gains the role inventory, LibreCAD setup requirements, approval gates, and limitations.
- Runtime consumers may need `aiblueprint-mcp`, LibreCAD 2.2.1+, `uv` or Docker, a writable isolated drawing workspace, and Xvfb for headless previews.
- No new CAD library is embedded in the repository, and no source DXF, credential, or personal room imagery is persisted by this change.

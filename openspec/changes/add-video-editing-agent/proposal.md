## Why

The repository has general-purpose OpenCode roles but no focused environment for
video production, leaving composition, footage editing, and render safety to
ad-hoc prompts. A dedicated agent can combine HyperFrames composition guidance,
OpenMontage's staged production discipline, and Kdenlive timeline control while
preserving explicit approval boundaries for media mutations and exports.

## What Changes

- Add a `video-editing-assistant` OpenCode environment to the existing Home Manager module.
- Add a repository-managed video-editing skill covering intake, media inspection, storyboards, editing, previews, QC, and delivery.
- Incorporate adapted workflow guidance from HyperFrames and OpenMontage without vendoring their upstream skill collections.
- Declare the D-Ogi Kdenlive MCP server as the agent's only editing-specific MCP integration.
- Require approval before timeline mutation, project saves, media deletion or replacement, rendering, and export operations.
- Document runtime prerequisites, MCP setup, project-root expectations, supported editing paths, and known limitations.
- Extend focused generated-configuration tests for the agent, skill materialization, MCP isolation, permissions, and secret/path safety.

## Capabilities

### New Capabilities

- `video-editing-agent`: A declarative OpenCode environment for safe, evidence-backed video production and Kdenlive editing.

### Modified Capabilities

None.

## Impact

- `home-modules/opencode-agents/definitions.nix` for the role, shared skill, and MCP declaration.
- `tests/opencode-agents.nix` for generated configuration and isolation coverage.
- `docs/opencode-agents.md` for installation, usage, prerequisites, and safety behavior.
- The external runtime environment: HyperFrames, FFmpeg, Python, Kdenlive, and the D-Ogi `mcp-kdenlive` server remain consumer-provided prerequisites.
- Upstream references: HyperFrames is Apache-2.0; OpenMontage is AGPL-3.0; the agent will link to and adapt workflow concepts rather than copy upstream skill corpora.

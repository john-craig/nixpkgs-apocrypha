## Context

See `proposal.md` for motivation. The existing module generates one isolated
OpenCode JSON environment per role, materializes shared skills and rules, and
supports per-role local MCP declarations. Its MCP type can represent a local
command and arguments but does not validate whether a server is installed or
whether a project root is safe at runtime.

The external research establishes three complementary layers: HyperFrames provides
HTML-native deterministic composition and agent skills; OpenMontage provides a
stage-based production protocol, checkpoints, approvals, and QC; Kdenlive MCP
provides direct NLE operations through a running Kdenlive instance. The selected
backend is [D-Ogi/mcp-kdenlive](https://github.com/D-Ogi/mcp-kdenlive), which wraps
`kdenlive-api` and exposes composite timeline, media, transition, marker, checkpoint,
and render tools.

## Goals / Non-Goals

**Goals:**

- Add one auditable, isolated primary agent to the existing definitions inventory.
- Encode the common production lifecycle and safety gates as a concise repository skill.
- Keep HyperFrames and OpenMontage upstream knowledge linked and adapted rather than copied wholesale.
- Declare Kdenlive MCP access without asserting that Kdenlive, its patched API, Python, or FFmpeg are installed.
- Provide generated-configuration tests for behavior that Nix evaluation can verify.

**Non-Goals:**

- Packaging Kdenlive, `kdenlive-api`, FFmpeg, Python, or the MCP server in this change.
- Implementing a video pipeline, media index, render service, or project database.
- Vendoring HyperFrames' or OpenMontage's skill collections.
- Guaranteeing Kdenlive mutation safety through Nix alone; the role prompt and user approval remain part of the control boundary.
- Adding a new runner or changing unrelated environments.

## Decisions

### Keep the role in `definitions.nix`

Add `video-editing-assistant` beside the existing named roles and select shared
skills for evidence, approval gating, source integrity, and video editing. This
reuses the current JSON generation, role isolation, permission defaults, and
Home Manager export.

Alternative considered: create a separate video-specific module. Rejected because
the requested behavior is a role definition and the existing module already owns
skills, rules, MCP declarations, and generated environments.

### Use a concise adapter skill

The new skill will define the staged workflow, runtime decision, approval gates,
source-preservation rules, and reporting contract. It will link to upstream
HyperFrames and OpenMontage documentation for detailed domain knowledge.

Alternative considered: copy upstream skills into the repository. Rejected because
OpenMontage is AGPL-3.0, its corpus is large and fast-moving, and copying would
create maintenance and licensing obligations disproportionate to this agent.

### Target D-Ogi's stdio MCP server

The initial declaration will target the documented local command form, based on
`python -m mcp_kdenlive`, with runtime prerequisites documented separately:
Python 3.10+, `kdenlive-api`, MCP SDK, and a patched Kdenlive with its D-Bus API.
The role will not enable arbitrary shell execution merely because the MCP server
is configured.

Alternative considered: AMMIROSOH/Kdenlive-mcp. Rejected for this change because
the user selected the direct D-Ogi backend; it can be evaluated in a later change
if root containment, revisioned projects, and built-in QC are preferred.

### Treat availability as runtime state

Nix tests will verify MCP structure, role isolation, and secret/path safety only.
They will not start Kdenlive or execute the external server. Documentation will
make the distinction explicit and the agent will fail closed when the integration
cannot be reached.

### Use approval permissions instead of implicit autonomy

The role will allow inspection and research, while edit, bash, task, and MCP
operations remain approval-gated unless a narrowly scoped permission override is
explicitly configured by the consumer. The prompt will distinguish read-only
analysis from state-changing MCP tools because the current generic permission type
cannot classify individual Kdenlive operations.

## Risks / Trade-offs

- [D-Ogi's server requires patched Kdenlive and external Python dependencies] → Document exact prerequisites and test configuration without claiming live availability.
- [The generic MCP schema cannot validate command semantics or per-tool mutation] → Keep defaults conservative, require approval in the role, and document the limitation.
- [The command may require consumer-specific arguments or a project context] → Keep the declaration minimal and make command/root customization a follow-up if the chosen installation needs it.
- [Upstream skills and APIs may drift] → Record canonical URLs and access date in documentation; avoid copying large upstream files.
- [Video renders and timeline mutations are expensive or destructive] → Require stage approvals, snapshots or working copies, previews, and evidence-backed final reporting.

## Migration Plan

1. Enable the existing `homeModules.opencode-agents` module as usual; the new role is generated alongside existing roles.
2. Install and configure the D-Ogi MCP server and its Kdenlive prerequisites separately.
3. Select `video-editing-assistant` through the existing generated environment or runner.
4. To roll back, remove the role definition or disable the module; no existing environment or project files are migrated.

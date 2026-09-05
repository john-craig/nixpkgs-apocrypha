## 1. Module Layout

- [x] 1.1 Inventory every named agent, shared skill, rule, and subagent in `definitions.nix`; verify the inventory matches generated configuration names before extraction.
- [x] 1.2 Create `home-modules/opencode-agents/shared/` for role helpers and shared definitions; verify the existing module option schema remains unchanged.
- [x] 1.3 Create one `home-modules/opencode-agents/agents/<name>/default.nix` entrypoint for every named agent and preserve each role body verbatim; verify all expected names are explicitly imported.
- [x] 1.4 Replace the monolithic declarations with a small explicit aggregator; verify duplicate or missing imports fail clearly during Nix evaluation.

## 2. Behavioral Preservation

- [x] 2.1 Preserve role construction, defaults, permission merging, authentication, project discovery, prompt generation, and shared-content selection; verify representative generated JSON is unchanged apart from derivation source paths.
- [x] 2.2 Preserve MCP declarations and role isolation, including Godot, podcast, research, deployment, media, and remote-diagnostics roles; verify each generated environment contains only its declared MCP servers.
- [x] 2.3 Preserve default-agent selection, subagent profiles, generated prompt/skill/rule paths, and the `opencode-agent` runner; verify existing consumers need no configuration changes.

## 3. Tests and Documentation

- [x] 3.1 Extend `tests/opencode-agents.nix` with source-inventory and generated-output assertions for every agent name; verify enabled/disabled evaluation and unknown-definition failures remain correct.
- [x] 3.2 Add focused checks for shared-definition reuse and role-local isolation; verify sensitive permissions and MCP declarations remain unchanged for representative roles.
- [x] 3.3 Update `docs/opencode-agents.md` or contributor documentation with the new maintainer source layout; verify user-facing generated paths and invocation examples remain unchanged.

## 4. Verification and Handoff

- [x] 4.1 Run formatting, focused OpenCode-agent checks, full `nix flake check`, and `openspec validate --specs`; verify all existing checks pass.
- [x] 4.2 Review the final diff for accidental prompt, model, permission, MCP, generated-path, or public-option changes; verify only the approved source-organization refactor is present.

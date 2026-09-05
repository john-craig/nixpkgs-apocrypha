## Why

`home-modules/opencode-agents/definitions.nix` currently contains every shared skill, rule,
subagent, and named agent in one large file. Splitting each agent definition into a dedicated
subdirectory will make role ownership, review, and future edits easier without changing the
generated OpenCode behavior.

## What Changes

- Move named agent definitions into `home-modules/opencode-agents/agents/<name>/` with one
  entrypoint per agent.
- Move agent-specific prompts, skills, rules, and MCP declarations alongside their owning
  agent where practical, while retaining shared definitions in a clearly named shared area.
- Add a small aggregator/import layer that preserves the current `evak.opencode-agents`
  option shape, generated paths, role names, permissions, and default behavior.
- Update tests, flake packaging, and documentation only where paths or source organization are
  observable to maintainers; generated user-facing configuration remains unchanged.
- Preserve existing custom-module extension points and fail clearly for missing or duplicate
  agent definitions.

## Capabilities

### New Capabilities

None. This is an internal source-organization refactor.

### Modified Capabilities

None. Generated agent behavior and public configuration contracts remain unchanged.

## Impact

- `home-modules/opencode-agents/definitions.nix` and new files under
  `home-modules/opencode-agents/agents/` and `home-modules/opencode-agents/shared/`.
- Existing Nix evaluation and generated-configuration tests, plus any source-path references
  in documentation or contributor guidance.
- No runtime dependencies, generated JSON paths, agent names, permissions, prompts, MCP
  declarations, or user configuration options should change.

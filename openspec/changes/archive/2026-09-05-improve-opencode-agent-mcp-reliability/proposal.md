## Why

Several OpenCode agents use MCP servers whose generated permissions and startup
timeouts are not consistently aligned with their intended policies. A restrictive
wildcard can suppress otherwise declared MCP tools, while the current generator
also emits unconditional per-server allows and leaves many slow-starting servers
at the five-second discovery timeout. This change makes MCP-backed agents
predictable and preserves their declared approval boundaries.

## What Changes

- Make generated MCP tool permissions honor the agent's declared MCP approval
  policy instead of unconditionally assigning per-server `allow` rules.
- Define and apply suitable MCP discovery timeouts for local package-based,
  remote, and credential-backed servers, with explicit overrides where needed.
- Audit all MCP-bearing agent definitions for tool exposure, permission
  consistency, transport configuration, and startup reliability.
- Add regression checks covering MCP server declarations, generated tool rules,
  permission boundaries, and configured discovery timeouts.

## Capabilities

### New Capabilities

<!-- None. This change tightens and clarifies existing MCP behavior. -->

### Modified Capabilities

- `opencode-agent-environments`: MCP servers SHALL be exposed according to each
  environment's declared permission and startup policy, without suppressing
  usable tools or bypassing approval-gated operations.
- `opencode-agent-runner`: direct and Home Manager-installed runners SHALL
  preserve the corrected MCP tool availability, permission behavior, and
  discovery configuration.

## Impact

- `home-modules/opencode-agents/default.nix` and MCP-bearing agent definitions.
- Generated OpenCode environment JSON and associated test fixtures.
- Home Manager and flake runner validation for MCP-backed agents.
- No new external dependency is required; existing MCP commands, remote
  endpoints, and credential references remain in use.

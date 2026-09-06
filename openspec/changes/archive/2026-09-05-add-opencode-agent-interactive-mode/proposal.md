## Why

The flake-provided `opencode-agent` runner currently requires a non-empty prompt
and always invokes `opencode run`, so users cannot start a normal interactive
OpenCode session with one of the generated agent environments without deploying
Home Manager or manually locating the generated configuration.

## What Changes

- Add an explicit interactive mode to the flake-provided `opencode-agent` command.
- Let interactive mode select an agent and target directory using the same generated environments and validation as non-interactive mode.
- Invoke OpenCode's interactive terminal interface without requiring `--prompt` in interactive mode.
- Preserve the existing prompt-driven `opencode run` behavior and reject ambiguous combinations of interactive and prompt options.
- Document interactive `nix run` usage and add focused runner checks.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `opencode-agent-runner`: Extend the runner contract with an explicit interactive invocation while preserving non-interactive execution.

## Impact

- Affected files include `pkgs/opencode-agent/default.nix`, the Home Manager runner implementation if its interface is kept aligned, runner checks, and `docs/opencode-agents.md`.
- The runtime still requires an `opencode` executable and provider authentication.
- The change adds a CLI mode but does not alter generated agent permissions, prompts, MCP declarations, or credential handling.

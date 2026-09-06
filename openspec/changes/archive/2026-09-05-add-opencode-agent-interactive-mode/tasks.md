## 1. Runner Interface

- [x] 1.1 Add explicit `--interactive` parsing to the flake runner and preserve existing `--agent`, directory, prompt, and environment-root options; verify `--help` documents both modes.
- [x] 1.2 Implement interactive OpenCode invocation using the selected generated configuration and target directory; verify a fake OpenCode executable receives the expected configuration and directory with no prompt or `run` subcommand.
- [x] 1.3 Apply the same interactive-mode contract to the Home Manager runner while preserving its environment lookup behavior; verify existing prompt-driven invocations remain unchanged.
- [x] 1.4 Add validation for missing prompts in non-interactive mode and conflicting `--interactive` plus `--prompt` arguments; verify each failure exits before OpenCode is invoked.

## 2. Tests And Documentation

- [x] 2.1 Extend the flake package check with successful interactive execution, invalid argument cases, environment-root selection, and permission/configuration assertions; verify `nix build .#checks.x86_64-linux.opencode-agent --no-link` and `nix build .#checks.x86_64-linux.opencode-agents --no-link` pass.
- [x] 2.2 Update `docs/opencode-agents.md` with local and remote `nix run` interactive examples, runtime prerequisites, and the distinction between interactive and prompt-driven modes; verify the documented commands match the implemented CLI.
- [x] 2.3 Run focused OpenSpec validation and the relevant Nix checks; verify `openspec validate add-opencode-agent-interactive-mode --type change --strict` and the runner tests both pass.

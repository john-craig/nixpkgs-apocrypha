## 1. Agent Definitions

- [x] 1.1 Add the `software-architect` role with the `openai/gpt-5.6-sol` model, specification-focused prompt, and explicit non-mutating permissions; verify generated JSON contains the model, role mode, prompt, and denied mutation tools
- [x] 1.2 Change the developer role's default permissions to allow file edits and command execution while preserving explicit overrides; verify a generated developer environment reflects autonomous permissions and a restricted override still wins
- [x] 1.3 Update the agent documentation with the architect role, autonomy behavior, permission override example, and direct invocation examples; verify documented names and paths match generated configuration

## 2. Agent Runner

- [x] 2.1 Implement the `opencode-agent` executable with `--agent`, `--directory`, and `--prompt` arguments; verify it resolves the selected generated environment and delegates the exact values to `opencode run`
- [x] 2.2 Expose the runner through the enabled Home Manager module and ensure it uses the configured OpenCode executable; verify disabled module evaluation does not install the command
- [x] 2.3 Validate unknown agents, invalid directories, and empty prompts before launching OpenCode; verify each case exits non-zero and the fake OpenCode executable is not invoked
- [x] 2.4 Preserve selected-agent permissions and OpenCode exit status without implicitly adding `--auto`; verify a fake OpenCode invocation receives the expected environment and returns the wrapped exit code

## 3. Verification

- [x] 3.1 Extend the focused agent evaluation check for the new role, developer permissions, generated environment isolation, and no secret leakage; verify `nix build .#checks.x86_64-linux.opencode-agents` passes
- [x] 3.2 Add runner integration checks covering paths and prompts containing spaces, quotes, and newlines; verify exact argument preservation and safe failure behavior
- [ ] 3.3 Run formatting and the complete flake check suite; verify `nix flake check` passes without changing unrelated worktree files

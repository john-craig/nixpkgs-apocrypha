## 1. Shared Environment Generation

- [x] 1.1 Reuse the Home Manager module's agent environment, prompt, skill, rule, and permission generation in a package-time evaluator and verify the existing `nix build .#checks.x86_64-linux.opencode-agents` check remains unchanged
- [x] 1.2 Generate package-local environments for every current configured agent from the shared definitions and verify all expected agent JSON and supporting files are present

## 2. Flake Runner Package

- [x] 2.1 Add the flake-provided `opencode-agent` package and expose it through `default.nix`, `legacyPackages`, and flake package outputs; verify `nix build .#opencode-agent` succeeds
- [x] 2.2 Implement default packaged-environment resolution and an explicit environment-root override, including fail-closed validation; verify invalid roots and unknown agents do not invoke a fake OpenCode executable
- [x] 2.3 Preserve exact agent, directory, and prompt forwarding without adding automatic approval bypasses; verify a fake OpenCode executable receives the expected `run`, `--dir`, `--agent`, and prompt arguments

## 3. Security and Compatibility

- [x] 3.1 Verify representative restricted and approval-gated agents retain their generated permissions, prompts, MCP declarations, and model settings in direct execution
- [x] 3.2 Add package checks proving generated outputs contain no credentials, secret values, or machine-specific secret contents and that Home Manager activation behavior remains compatible

## 4. Documentation and Verification

- [x] 4.1 Document `nix run <flake>#opencode-agent`, required runtime OpenCode authentication, packaged environments, and the environment-root override
- [x] 4.2 Run `git diff --check`, `openspec validate run-opencode-agent-from-flake --type change --strict`, and the focused OpenCode agent check; verify all pass and review the generated direct invocation behavior

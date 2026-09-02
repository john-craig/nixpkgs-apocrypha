## 1. Dependency And Module Contract

- [x] 1.1 Add and lock the `github:albertov/opencode-nix` flake input, wire its overlay/library into the repository, and verify `nix flake check` evaluates the dependency.
- [x] 1.2 Define typed `evak.opencode-agents` options in `home-modules/opencode-agents` for named agents, shared skills/rules/subagents, MCP servers, model overrides, permissions, authentication references, and default selection; verify invalid names and missing required references fail evaluation.
- [x] 1.3 Export `homeModules.opencode-agents` alongside `homeModules.opencode`; verify both modules can be imported together without changing the existing customization behavior.

## 2. OpenCode Configuration Generation

- [x] 2.1 Compose `opencode-nix` typed modules to generate OpenCode `agent` entries with primary/subagent modes, prompts, descriptions, models, and permissions; verify representative output passes the upstream schema check.
- [x] 2.2 Generate named skills, rules, and prompt files in the supported OpenCode configuration directory layout; verify names and instruction text are preserved and paths are deterministic.
- [x] 2.3 Generate explicit MCP definitions with local/remote transport, command or URL, arguments, enabled state, and secret references; verify credentials do not occur in store-generated configuration.
- [x] 2.4 Implement default-agent selection and environment isolation; verify two configured roles do not inherit each other's prompts, MCP servers, or permissions.

## 3. Panoply Migration

- [x] 3.1 Port the 15 Panoply environments and record each source-to-OpenCode mapping in migration documentation; verify every source environment is accounted for.
- [x] 3.2 Port reusable skills, rules, and subagent profiles with explicit per-role selection; verify representative role content and safety boundaries against the Panoply source.
- [x] 3.3 Map model and Codex settings to OpenCode equivalents and document unsupported behavior; verify unsupported fields are not emitted as misleading OpenCode settings.
- [x] 3.4 Port MCP declarations and authentication/isolation intent without copying secrets or asserting runtime availability; verify fail-closed behavior for missing credentials.

## 4. Documentation And Verification

- [x] 4.1 Document module import, enablement, environment selection, generated paths, OpenCode invocation, authentication references, MCP prerequisites, and compatibility limits; verify all documented paths match generated output.
- [x] 4.2 Add focused Nix evaluation checks for disabled/enabled `opencode-agents` behavior, composition with `opencode`, default selection, role isolation, agent permissions, MCP structure, and secret non-leakage; verify the checks pass without live services.
- [x] 4.3 Run formatting, targeted checks, and full `nix flake check`; inspect the final diff and verify unrelated existing changes remain untouched.

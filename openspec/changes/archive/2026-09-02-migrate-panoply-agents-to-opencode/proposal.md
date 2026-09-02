## Why

Panoply currently contains 15 declarative agent environments coupled to Codex-specific homes, settings, and launch behavior, while this repository already owns the user-facing OpenCode Home Manager module. Migrating the environments here will provide one reproducible OpenCode configuration surface and remove the dependency on Panoply for agent-role configuration.

## What Changes

- Add a dedicated `home-modules/opencode-agents` Home Manager module for repository-owned declarative OpenCode agents.
- Migrate the existing Panoply environments, reusable skills, rules, subagents, prompts, MCP definitions, model choices, and isolation intent into OpenCode-compatible configuration.
- Use `github:albertov/opencode-nix` for typed OpenCode configuration generation and its supported OpenCode package integration rather than inventing a parallel schema adapter.
- Export the migrated environments as `homeModules.opencode-agents`, composable alongside the existing `homeModules.opencode` customization module.
- Preserve authentication boundaries and avoid embedding secrets, tokens, or Panoply-only service implementations in generated configuration.
- Provide evaluation and generated-file checks covering environment selection, role content, MCP configuration, and disabled behavior.
- Document migration limits where Codex concepts do not have a direct OpenCode equivalent.
- **BREAKING**: The migrated environments will no longer be selected or materialized through Panoply's `agentEnvironments`/Codex launcher interface.

## Capabilities

### New Capabilities

- `opencode-agent-environments`: Declarative named OpenCode agents under `home-modules/opencode-agents`, with role prompts, skills, rules, subagents, MCP servers, model settings, authentication references, and isolation policy.

### Modified Capabilities

- `opencode-customizations`: Preserve the existing TUI customization module as an independent module that can be imported alongside `homeModules.opencode-agents` without requiring Panoply.

## Impact

- Affected flake inputs and outputs: add `opencode-nix`, compose its typed configuration modules, and use its OpenCode package integration where appropriate.
- Affected Home Manager code: new `home-modules/opencode-agents`, module exports, generated OpenCode JSON/Markdown files, and focused checks.
- Affected configuration consumers: users importing `homeModules.opencode-agents` will gain named agents; existing `homeModules.opencode` consumers retain the separate TUI customization contract.
- External integrations: MCP command/URL declarations remain configuration-only unless their executable and credentials are independently supplied; no secrets are copied from Panoply.
- Source migration: Panoply remains the reference during implementation, but the resulting configuration in this repository becomes authoritative for OpenCode.

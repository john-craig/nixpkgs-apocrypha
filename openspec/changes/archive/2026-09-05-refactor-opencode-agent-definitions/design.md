## Context

The OpenCode Home Manager module currently imports one `definitions.nix` file that declares
shared skills, rules, subagents, and all named agents. The module's public option schema and
generated files are stable and should remain the source-compatible contract. See
`proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Give every named agent a separate directory and a predictable entrypoint.
- Keep shared skills, rules, subagents, and construction helpers separate from role-owned
  definitions.
- Preserve evaluation order, generated JSON, prompt text, permissions, MCP declarations,
  agent names, default selection, and runner behavior.
- Make duplicate or missing role registration fail during Nix evaluation.

**Non-Goals:**

- Changing any agent's behavior, permissions, model, prompt, MCP server, or generated path.
- Reworking the Home Manager option schema or introducing a second configuration format.
- Moving unrelated OpenCode customization modules or changing runtime dependencies.

## Decisions

### Use one directory per named agent

Create `home-modules/opencode-agents/agents/<agent-name>/default.nix` for each named agent,
including the two recently added podcast roles and the Godot role. Each entrypoint returns a
role definition or a clearly scoped fragment. This makes ownership and review boundaries
obvious while retaining the existing kebab-case names.

### Keep shared definitions in a dedicated area

Move the `role` helper and shared skills, rules, and subagents to
`home-modules/opencode-agents/shared/`. Keep `definitions.nix` as a small aggregator that
imports the shared definitions and maps the agent directory names to their definitions.
Shared content remains explicitly selected by each role rather than implicitly merged.

### Use declarative imports, not filesystem discovery

The aggregator will import an explicit list or attribute set of agent entrypoints. Avoid
runtime `builtins.readDir` discovery because it weakens duplicate/missing-definition errors,
can accidentally include helper directories, and makes evaluation less transparent. The list
also provides a reviewable generated-agent inventory.

### Preserve merge semantics

Each agent entrypoint will use the existing `role` helper and Nix attribute merging pattern.
The refactor must not alter `lib.mkDefault`, permission precedence, shared skill selection,
MCP declarations, authentication defaults, or prompt generation. Existing tests will compare
representative generated outputs and all agent names before and after the move.

### Treat source paths as maintainer-facing only

Generated paths remain unchanged. Documentation may describe the new source layout, but user
configuration continues to import `homeModules.opencode-agents` and select the same names.

## Risks / Trade-offs

- **Imports can omit or duplicate an agent** → maintain an explicit inventory and assert the
  expected names during evaluation and focused tests.
- **Relative import changes can alter evaluation** → use small module smoke evaluations and
  run the complete flake checks after the move.
- **Large mechanical diff obscures behavior changes** → preserve role bodies verbatim during
  extraction and compare generated JSON/prompts for representative and sensitive roles.
- **Shared content can accidentally become role-local or vice versa** → test selected skill,
  rule, subagent, and MCP isolation for roles with distinct configurations.

## Migration Plan

1. Add shared and per-agent module files while preserving the current definitions.
2. Switch the module to the new aggregator and remove the monolithic role declarations.
3. Update tests and maintainer documentation for source layout and inventory checks.
4. Run formatting, focused checks, full flake evaluation, and diff review.
5. Roll back by restoring the monolithic definitions file; no generated user files or runtime
   data require migration.

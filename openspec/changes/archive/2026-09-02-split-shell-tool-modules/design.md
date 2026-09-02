## Context

See `proposal.md` for motivation. The repository currently has three aggregate Home Manager modules: nine CLI tools in `shell-cli-tools`, four development tools in `shell-development-tools`, and SSH client/agent/host configuration in `shell-ssh`. The repository already uses one directory per independently exported module for features such as OpenCode, tmux, VSCodium, and zsh.

## Goals / Non-Goals

**Goals:**

- Give each independently configurable tool a dedicated module directory and focused file.
- Preserve existing `evak.shell.cli`, `evak.shell.development`, and `evak.shell.ssh` option paths and behavior.
- Preserve aggregate imports as compatibility composition modules unless their removal is proven safe.
- Keep shared helpers small and explicit rather than recreating duplicated logic.
- Add per-tool and aggregate evaluation coverage.

**Non-Goals:**

- Redesigning tool options or changing package defaults.
- Adding new tools, shell aliases, ambient environment variables, or service integrations.
- Changing secret storage, deployment behavior, SSH topology semantics, or portable Nix scope.
- Removing aggregate module exports in this change without evidence that no consumer relies on them.

## Decisions

### One directory per public tool

Create directories named after the public module identity, with `default.nix` as the entry point. The aggregate directories retain a `default.nix` that imports or composes their child modules. This matches the existing repository layout while keeping import paths predictable.

Alternative considered: retain one file and split only with local `let` bindings. Rejected because it does not improve module discovery or independent reuse.

### Preserve option namespaces

Child modules will continue to declare their existing nested options under `evak.shell.cli`, `evak.shell.development`, and `evak.shell.ssh`. Splitting is structural, so existing consumers do not need configuration rewrites.

Alternative considered: give every tool a new top-level namespace. Rejected because it creates an unnecessary compatibility break.

### Use explicit composition imports

Aggregate modules will import child modules and provide no duplicated implementation. Shared helper types or functions will move to narrowly scoped helper files only when multiple children need them.

Alternative considered: make consumers import every child module manually. Rejected as the default because it breaks existing aggregate imports and increases migration cost.

### Keep tests at both levels

Focused checks will evaluate each child module's disabled/enabled behavior and the aggregate imports. This catches missing imports, option collisions, accidental package activation, and regressions in secret activation or host validation.

## Risks / Trade-offs

- [Option collisions during composition] -> Evaluate all child modules together and retain exact option paths.
- [Hidden consumers import aggregate file paths directly] -> Keep aggregate modules and public exports stable; document child imports as additive.
- [Activation ordering changes] -> Preserve existing Home Manager activation names and dependencies, then test credential installation and generated files.
- [Large diff across many directories] -> Migrate one functional group at a time and run focused checks after each group.
- [Unclear ownership of shared SSH helpers] -> Keep SSH host configuration, agent setup, and helper packages separate only where their options and behavior are independently meaningful.

## Migration Plan

1. Inventory every option, package, generated file, activation action, and assertion in the three aggregate modules.
2. Create child module directories and move one tool's behavior at a time without changing option paths.
3. Replace aggregate implementations with imports/composition and retain their existing exports.
4. Update module exports, documentation, OpenSpec main specs, and focused checks.
5. Run formatting, targeted checks, and the full flake checks.

Rollback is a source-level revert of the split while preserving the public option contract; no persistent data migration is expected.

## Open Questions

- Whether `shell-ssh` should split into exactly SSH client, SSH agent, host topology, and helper modules or use a finer tool-based grouping can be finalized during implementation without changing the public behavior requirements.

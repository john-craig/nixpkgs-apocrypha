## Why

The shell tool modules currently group unrelated applications behind three large aggregate files, unlike the repository's established one-module-per-tool layout. Splitting them will make ownership, option discovery, testing, and future changes more localized while preserving the current user-facing behavior.

## What Changes

- Create a separate Home Manager module directory for every tool currently defined in `shell-cli-tools`, `shell-development-tools`, and `shell-ssh`.
- Move each tool's options, package handling, generated files, activation logic, and program configuration into its own module.
- Retain the existing public module exports and option paths unless a compatibility issue is explicitly identified and documented.
- Reduce the three aggregate modules to compatibility aggregators, or remove them only if repository conventions and consumers permit a safe transition.
- Preserve package availability assertions, secret-path handling, restrictive permissions, SSH host validation, Git configuration, direnv integration, and portable Nix boundaries.
- Update documentation, tests, and OpenSpec references to describe the per-tool layout.
- **BREAKING**: No intentional user-facing option or behavior break is planned; any unavoidable export or import change must include a migration path.

## Capabilities

### New Capabilities

None. This is a structural refactor of existing capabilities.

### Modified Capabilities

- `shell-cli-tools`: Change the module layout and public composition while preserving independent enablement and behavior for all nine CLI tools.
- `shell-development-tools`: Change the module layout and public composition while preserving independent Git, GitHub CLI, direnv, and Nix tooling behavior.
- `shell-ssh`: Change the module layout and public composition while preserving SSH client, agent, host validation, and helper-package behavior.

## Impact

- Affected files: `home-modules/shell-cli-tools`, `home-modules/shell-development-tools`, `home-modules/shell-ssh`, `home-modules/default.nix`, tests, README/docs, and the three corresponding main specs.
- Public API: existing `homeModules` exports and `evak.shell.*` option paths should remain stable; module imports may become more granular.
- Tests: aggregate checks must be adapted to evaluate individual modules and their compatibility aggregators.
- Consumers: Home Manager configurations importing the aggregate modules should continue to work during the transition.

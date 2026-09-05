## Why

The repository documents a repeatable workflow for selecting an OpenSpec change,
running an OpenCode implementation agent, and publishing the result, but the
workflow is currently manual and tied to a particular Grimoire example. A
Home Manager-installed command would make the workflow reusable for arbitrary
GitHub and Gitea repositories while keeping repository credentials and provider
configuration in the user's runtime environment.

## What Changes

- Add a Home Manager module under
  `home-modules/project-manager/automated-development-workflows/implementor`.
- Install one `openspec-implementor` command when the module is enabled.
- Accept an upstream Git repository URL and optionally an explicit OpenSpec
  change name.
- Use `openspec status --json` to identify incomplete active changes.
- Skip changes with an existing pending pull request unless `--force` is used.
- Create an isolated temporary worktree on `feature/<change-name>`.
- Select an OpenCode agent from a valid `<agent-name>-...` change prefix, or use
  `developer` as the fallback.
- Instruct the agent to implement, validate, sync, and archive the selected
  change without publishing it.
- Commit, push, and open a pull request after the agent succeeds.
- Support GitHub through `gh` and Gitea through `tea`, with provider selection
  inferred from the upstream URL and optionally overridden.
- Clean up temporary repository state after successful publication and provide
  an option to preserve failed worktrees for diagnosis.
- Add focused checks and documentation for the command and module.

## Capabilities

### New Capabilities

- `openspec-implementor-workflow`: Isolated, agent-driven implementation and
  pull-request publication for unfinished OpenSpec changes in upstream Git
  repositories.

## Impact

- Adds a public Home Manager module and command export.
- Adds runtime dependencies on Git, OpenSpec, the flake-provided
  `opencode-agent` runner, and the provider CLI needed for the selected
  upstream host.
- Adds provider and repository lifecycle tests using fake commands and local
  repositories; tests must not require live credentials or mutate remote state.
- Extends the automated development workflow documentation.
- Does not change Sceptre. The current Sceptre `specset publish` command is
  specialized for Grimoire manifests, so the generic workflow uses Git and
  `gh` or `tea` directly unless a future Sceptre interface applies.

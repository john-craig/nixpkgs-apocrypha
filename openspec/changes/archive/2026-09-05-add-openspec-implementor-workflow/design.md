## Context

The repository already exposes a flake-provided `opencode-agent` runner and
declarative OpenCode environments, including `developer` and several specialist
roles. The automated development workflow directory currently contains manual
instructions for creating worktrees, running agents, committing changes, and
opening Gitea pull requests. The existing `tea` and GitHub Home Manager modules
provide package and credential configuration, but no single workflow command.

OpenSpec provides machine-readable lifecycle commands. In particular,
`openspec status --change NAME --json` reports planning and artifact state, and
`openspec archive NAME --yes` validates, synchronizes delta specs, and moves a
completed change into the archive. These commands should be the workflow's
source of truth rather than parsing `tasks.md` directly.

The pinned Sceptre package supports provider-aware Git operations and
Grimoire-specific `specset publish`, but its publish interface requires a
manifest and catalog. It cannot publish arbitrary repository-local OpenSpec
changes, so this change should not force unrelated repositories into the
Grimoire catalog model.

## Goals / Non-Goals

**Goals:**

- Provide one Home Manager-installed command for the complete generic workflow.
- Keep target repositories isolated from the user's existing checkouts.
- Make change selection, agent selection, pending-PR handling, and publication
  deterministic and idempotent.
- Preserve provider credentials as external runtime configuration.
- Fail before publication when implementation, validation, archival, commit, or
  provider operations fail.
- Make cleanup and failure recovery explicit and testable.

**Non-Goals:**

- Do not modify or merge pull requests.
- Do not add a generic implementation command to Sceptre in this change.
- Do not make the OpenCode agent push, commit, or open a pull request.
- Do not support arbitrary version-control systems beyond GitHub and Gitea.
- Do not infer implementation completion by parsing task checkboxes when the
  OpenSpec status command is available.
- Do not copy credentials, provider configuration, or repository secrets into
  the Nix store or generated Home Manager files.

## Decisions

### Public module and command

Add a module at
`home-modules/project-manager/automated-development-workflows/implementor` and
export it from `home-modules/default.nix` under a stable project-manager name.
When enabled, the module installs exactly one primary command,
`openspec-implementor`.

The module should follow existing package-override patterns. Package options
should be nullable where the package may not exist in the selected nixpkgs,
with assertions that identify the missing dependency when the module is
enabled. The provider CLIs may be optional at evaluation time, but the command
must fail with an actionable runtime error when the selected provider is not
available.

### Command interface

The command accepts an upstream URL and supports these options:

```text
openspec-implementor --upstream URL
openspec-implementor --upstream URL --change NAME
openspec-implementor --upstream URL --force
openspec-implementor --upstream URL --provider github|gitea
openspec-implementor --upstream URL --base BRANCH
openspec-implementor --upstream URL --work-root PATH
openspec-implementor --upstream URL --keep-worktree
```

The command should reject missing, malformed, or unsupported inputs before
cloning. The upstream URL is the canonical input; repository owner/name and
provider identity are derived from it. `--provider` is an override for hosts
whose URL cannot be classified reliably.

### Change discovery and eligibility

The command clones the upstream repository into temporary state, then runs the
OpenSpec CLI from the cloned repository. Automatic selection uses
`openspec list --json` followed by `openspec status --change NAME --json` for
candidate changes. A change is eligible when it is active, valid enough for
implementation, and not reported complete by OpenSpec.

An explicit `--change` must identify an active eligible change; it must not
silently fall back to another change. Automatic selection must use stable
ordering, preferably the order returned by OpenSpec sorted by change name, so
repeated runs do not race over an arbitrary directory listing.

The workflow should report skipped, invalid, and selected changes without
printing secrets or unbounded provider output.

### Agent resolution and invocation

The command resolves a change prefix only when the first component before the
first hyphen is a valid configured OpenCode agent name. For example,
`software-architect-add-cache` selects `software-architect`; an unrecognized
prefix selects `developer`.

The command invokes the existing `opencode-agent` runner with the selected
temporary worktree and a prompt containing the exact change name. The prompt
must require the agent to:

- inspect the repository and OpenSpec artifacts;
- implement all required work;
- run focused tests and relevant repository checks;
- use `openspec` instructions as needed;
- run `openspec archive NAME --yes` only after implementation and validation;
- avoid committing, pushing, opening pull requests, changing unrelated files,
  or mutating external systems.

The wrapper must not add `--auto` or otherwise override the selected agent's
OpenCode permissions.

### Repository and worktree isolation

The workflow uses a temporary clone or bare clone as the Git worktree owner.
It fetches the upstream default branch, creates
`feature/<change-name>`, and runs the agent from that branch. The branch name
must be validated against Git ref rules and the OpenSpec change-name rules
before use.

The user's existing checkout must never be modified. A cleanup trap removes
temporary state after successful publication. On failure, the command removes
the temporary state by default only when doing so cannot hide useful agent
changes; `--keep-worktree` always preserves it and reports its path.

### Pending pull requests and idempotency

Before running an agent, the command queries the selected provider for open,
unmerged pull requests whose head branch is `feature/<change-name>`. A matching
pending request causes automatic selection to skip the change. An explicit
selection fails with a clear message instead of selecting another change.
`--force` bypasses this guard.

The branch name is the primary idempotency key. The workflow should not create
a second pull request for the same branch when the provider reports an
existing request, even if `--force` is used; force permits another
implementation attempt, not duplicate publication.

### Commit and publication

After the agent exits successfully, the wrapper verifies that the selected
change was archived, runs `git diff --check`, verifies the expected branch,
and confirms there are changes to commit. It commits the complete reviewed
worktree using a deterministic message such as
`Implement OpenSpec change <change-name>`.

It then pushes the branch and creates one pull request against the detected
default branch. Pull-request title and description should identify the exact
OpenSpec change and upstream URL without including local paths, credentials,
or arbitrary unbounded agent output.

GitHub publication uses `gh`; Gitea publication uses `tea`. Provider commands
must be invoked with bounded, structured output where supported. Git transport
continues to use the upstream URL and the user's configured SSH or HTTPS
credentials.

### Sceptre boundary

The implementation may expose a future adapter point for Sceptre, but the
initial command should not invoke `sceptre specset publish` for a repository
that lacks the required Grimoire manifest and catalog. The generic path must
remain independent and functional with Git plus the provider CLI.

## Risks / Trade-offs

- [An agent may modify unrelated files] -> Verify the selected change was
  archived, run diff checks, document the commit boundary, and preserve failed
  worktrees for diagnosis.
- [A provider query may miss a pending request] -> Use the canonical branch
  name as the idempotency key and check again immediately before PR creation.
- [OpenSpec CLI JSON may evolve] -> Validate required fields, fail closed on
  unrecognized status data, and test representative JSON fixtures.
- [Automatic cleanup may destroy useful debugging state] -> Support
  `--keep-worktree`, report cleanup failures, and retain failed state when the
  agent leaves uncommitted changes.
- [GitHub and Gitea CLIs differ] -> Keep provider operations behind a small
  adapter with separate fake-command tests and no provider-specific logic in
  change selection.
- [Sceptre may later gain a suitable generic interface] -> Keep provider and
  publication steps isolated so a future adapter can be added without changing
  change discovery or agent execution.

## Migration Plan

1. Implement and test the module and command without changing existing modules.
2. Export the module and document the runtime prerequisites and examples.
3. Run focused checks and the complete flake check suite.
4. Replace the duplicated manual workflow in the README with the new command,
   retaining lower-level recovery instructions where useful.
5. Roll back by removing the module export and command; existing OpenCode,
   Sceptre, Git, `gh`, and `tea` workflows remain unaffected.

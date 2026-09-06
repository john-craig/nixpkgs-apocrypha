## Context

The existing `openspec-implementor` command owns one implementation attempt,
including OpenSpec selection, isolated worktree creation, agent execution, commit,
push, and pull-request publication. The scheduler should orchestrate attempts
without duplicating that behavior.

The first version targets Linux Home Manager users and uses `systemd.user`. Generic
OpenSpec repositories are not Grimoire spec-set repositories, so the scheduler
must use the implementor's existing GitHub/Gitea provider adapters rather than
pretend that current `sceptre specset` commands can discover arbitrary OpenSpec
changes.

## Module Interface

Add a module under the project-manager automated workflow namespace with options
equivalent to:

```nix
evak.project-manager.automated-development-workflows.implementor-scheduler = {
  enable = true;
  interval = "6h";
  upstreams = [
    {
      url = "https://github.com/owner/project.git";
      provider = "github";
      baseBranch = "main";
    }
  ];
  retryOnFailure = false;
  model = null;
};
```

Repository entries SHALL validate the URL, provider, and base branch before
generating the service. The list order is significant. The interval SHALL be a
valid systemd timer interval. Runtime packages, implementor package, state path,
work root, and logging behavior SHALL be overridable for tests and deployments.

## systemd.user Units

Generate one `Type=oneshot` user service and one user timer. The timer SHALL use the
configured interval and SHALL not invoke the implementor directly. The service SHALL
acquire a non-blocking lock before selecting a repository. If the lock is held by a
previous invocation, it SHALL exit successfully as a skipped period and SHALL not
advance the cursor.

The service SHALL not enable persistence by default when the user was offline. A
configurable persistence option MAY emit `Persistent=true` when missed periods
should be replayed. A timer activation while the oneshot service is still running
must not queue a second implementation attempt.

## Round-Robin Selection

Store a small, atomically updated state record containing at least the next
repository index and a format/version marker under the user state directory. The
state file SHALL be created with private permissions and SHALL survive service
restarts. Invalid or missing state SHALL reset to index zero with a diagnostic.

At the beginning of each non-overlapping run, start at the persisted index and
inspect repositories in list order, wrapping at the end. After a repository is
selected for an implementation attempt, advance and persist the cursor before
running the implementor. This prevents a failing repository from starving the
others.

If a repository has no eligible OpenSpec change, immediately inspect the next
repository in the same run. If every repository has no eligible change, exit
successfully with a no-work result and retain the already-advanced cursor.

`retryOnFailure = false` SHALL retain the post-selection cursor after an
implementation failure. `retryOnFailure = true` SHALL restore the selected
repository as the next cursor after an implementation failure, but SHALL not retry
lock skips or repositories that simply had no eligible change.

## Implementor Invocation

For each repository candidate, invoke the existing `openspec-implementor` with the
repository URL, provider, base branch, and optional model/work-root arguments. The
scheduler SHALL not reimplement OpenSpec discovery, pending pull-request filtering,
agent selection, branch creation, or publication.

The scheduler SHALL classify the implementor result as success, no eligible work,
or failure using a stable machine-readable result or documented exit/status
contract. If the current implementor only emits human-readable diagnostics, add a
small structured status boundary without changing existing CLI behavior.

## Provider and Sceptre Boundary

The generic scheduler path SHALL use `gh` for GitHub and `tea` for Gitea through
the existing implementor/provider behavior. Credentials remain runtime concerns
and must never enter generated Nix files or state.

The current Sceptre commands are oriented around Grimoire catalogs and spec-set
manifests, not arbitrary repository OpenSpec directories. The initial scheduler
SHALL document this limitation and SHALL leave an integration seam for a future
generic Sceptre command, but SHALL not invoke `specset next`, `materialize`, or
`publish` for this workflow.

## Logging, Recovery, and Safety

Log the selected repository, selection outcome, implementor result, cursor action,
and elapsed time without logging credentials, review content, or full environment
variables. State writes SHALL use a temporary file plus rename. A stale lock SHALL
not permanently disable scheduling; use a lock primitive with process ownership.

The service SHALL preserve the implementor's `--keep-worktree` and failure
diagnostics options. A scheduler failure SHALL not advance beyond the cursor policy
already applied and SHALL not invoke a second repository concurrently.

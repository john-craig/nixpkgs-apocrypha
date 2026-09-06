## Why

The OpenSpec implementor can currently be run manually, but there is no
Home Manager service for continuously processing a known set of repositories.
Manual invocation also makes it difficult to distribute work fairly across
repositories or guarantee that a long implementation run is not overlapped by a
later scheduled invocation.

## What Changes

- Add a Linux `systemd.user` Home Manager module for periodically invoking
  `openspec-implementor`.
- Accept an ordered list of valid upstream repository definitions.
- Select repositories round-robin across runs and persist the cursor in user state.
- Try the next repository immediately when the selected repository has no eligible
  OpenSpec change.
- Advance the cursor after selection by default, with a configurable retry-on-
  failure option for implementation failures.
- Skip scheduled periods when an earlier implementation is still running.
- Use `gh` and `tea` for generic GitHub and Gitea OpenSpec repositories. Do not
  force the current Grimoire/spec-set-oriented `sceptre` commands into this
  generic workflow.

## Capabilities

### New Capabilities

- `openspec-implementor-scheduler`: A configured periodic user service for
  round-robin OpenSpec implementation across multiple upstream repositories.

## Impact

- Adds a Home Manager module, generated user service, generated user timer, and
  scheduler state/lock handling.
- Adds tests for scheduling, cursor persistence, overlap prevention, repository
  selection, and provider invocation.
- Extends workflow documentation with service configuration and operational
  behavior.
- Does not change the existing manual implementor CLI contract.

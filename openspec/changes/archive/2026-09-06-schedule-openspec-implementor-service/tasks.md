## 1. Home Manager Module and Units

- [x] 1.1 Add an opt-in scheduler Home Manager module under the project-manager automated workflow namespace.
- [x] 1.2 Add validated upstream repository options for URL, provider, base branch, and optional per-repository overrides.
- [x] 1.3 Generate a `systemd.user` oneshot service and timer with configurable interval and missed-period persistence.
- [x] 1.4 Add overridable package options for the implementor and lock utility, plus state and work roots.

## 2. Scheduling Runtime

- [x] 2.1 Implement atomic private cursor state with versioning, reset-on-invalid-state behavior, and round-robin wraparound.
- [x] 2.2 Implement a non-blocking process-owned lock that skips overlapping timer periods without advancing state.
- [x] 2.3 Advance the cursor after selection by default and restore it only for implementation failures when `retryOnFailure` is enabled.
- [x] 2.4 Continue immediately through later repositories when no eligible OpenSpec change is available and report an all-repositories-no-work result.
- [x] 2.5 Delegate each attempt to `openspec-implementor` with repository-specific provider, branch, model, and work-root arguments.

## 3. Provider and Sceptre Boundaries

- [x] 3.1 Verify pending pull-request skipping uses the existing `gh`/`tea` implementor behavior for generic OpenSpec repositories.
- [x] 3.2 Document that current Sceptre `specset` commands are intentionally not used for this generic scheduler path.
- [x] 3.3 Preserve a provider boundary that can adopt future generic Sceptre operations without changing scheduler semantics.

## 4. Tests and Documentation

- [x] 4.1 Add Home Manager evaluation tests for disabled/enabled modules, invalid options, generated service, timer, interval, and persistence settings.
- [x] 4.2 Add runtime tests for cursor progression, wraparound, retry policy, immediate next-repository scanning, no-work runs, and invalid state recovery.
- [x] 4.3 Add overlap-lock, interruption, credential-isolation, and failure-reporting tests.
- [x] 4.4 Add fake implementor/provider tests proving pending pull requests are skipped and only one implementation attempt runs per activation.
- [x] 4.5 Document service activation, state location, logs, manual triggering, timer behavior, retry semantics, and the generic `gh`/`tea` provider boundary.
- [x] 4.6 Run `openspec validate schedule-openspec-implementor-service --type change --strict`, focused checks, `git diff --check`, and `nix flake check`.

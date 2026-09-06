# openspec-implementor-scheduler Specification

## Purpose
Provides a Linux Home Manager `systemd.user` service and timer that periodically
run the OpenSpec implementor across a configured list of upstream repositories.

## Requirements

### Requirement: Home Manager scheduler module

The repository SHALL provide an opt-in Home Manager module that generates a user
service and timer for the OpenSpec implementor scheduler.

#### Scenario: Scheduler is disabled

- **WHEN** the scheduler module is disabled
- **THEN** it SHALL generate no scheduler service, timer, state directory, or
  implementor invocation

#### Scenario: Scheduler is enabled

- **WHEN** the scheduler is enabled with at least one valid upstream and interval
- **THEN** it SHALL generate one `systemd.user` oneshot service and one user timer
  with the configured interval

#### Scenario: Invalid configuration

- **WHEN** an upstream URL, provider, base branch, interval, or package option is
  invalid
- **THEN** Home Manager evaluation SHALL fail with an actionable error

### Requirement: Round-robin repository selection

The scheduler SHALL select configured upstream repositories in deterministic
round-robin order and SHALL persist the next repository cursor in private user
state.

#### Scenario: First run starts at the first repository

- **WHEN** the state file is absent or invalid
- **THEN** the scheduler SHALL begin at repository index zero and report the reset

#### Scenario: Selection advances the cursor

- **WHEN** a repository is selected for an implementation attempt
- **THEN** the scheduler SHALL persist the next repository index before invoking the
  implementor

#### Scenario: Cursor wraps

- **WHEN** selection advances beyond the final configured repository
- **THEN** the scheduler SHALL persist index zero

#### Scenario: Retry-on-failure is enabled

- **WHEN** `retryOnFailure` is enabled and the selected implementor attempt fails
- **THEN** the scheduler SHALL restore the failed repository as the next cursor

#### Scenario: Retry-on-failure is disabled

- **WHEN** `retryOnFailure` is disabled and the selected implementor attempt fails
- **THEN** the scheduler SHALL retain the already-advanced cursor

### Requirement: No-work scanning

The scheduler SHALL continue through the configured repository list when a selected
repository has no eligible OpenSpec change.

#### Scenario: Repository has no eligible change

- **WHEN** `openspec-implementor` reports that a repository has no eligible change
- **THEN** the scheduler SHALL immediately inspect the next repository without
  waiting for the next timer period

#### Scenario: All repositories have no eligible change

- **WHEN** every repository has no eligible change or only changes with pending pull
  requests
- **THEN** the scheduler SHALL exit successfully, report no work, and SHALL not
  invoke an agent or publish a pull request

### Requirement: Implementor delegation

The scheduler SHALL delegate implementation attempts to the existing
`openspec-implementor` command and SHALL pass each repository's URL, provider, base
branch, and configured optional model.

#### Scenario: Eligible repository is selected

- **WHEN** a repository has an eligible OpenSpec change
- **THEN** the scheduler SHALL invoke `openspec-implementor` for that repository
  without duplicating change selection or publication logic

#### Scenario: Pending pull request exists

- **WHEN** the repository contains only changes with pending pull requests
- **THEN** the scheduler SHALL treat the repository as having no eligible work and
  continue to the next repository

### Requirement: Non-overlapping execution

The scheduler SHALL skip a timer period when an earlier scheduler service process is
still running.

#### Scenario: Previous run is active

- **WHEN** the service starts while another scheduler process owns the run lock
- **THEN** it SHALL exit successfully as a skipped period and SHALL not advance
  repository state or invoke the implementor

#### Scenario: Previous run has finished

- **WHEN** the run lock is available
- **THEN** the scheduler SHALL acquire it and perform at most one implementation
  attempt during that service activation

### Requirement: systemd user timer behavior

The scheduler SHALL use a `systemd.user` timer to trigger the oneshot service at the
configured interval.

#### Scenario: Timer interval is configured

- **WHEN** the module receives a valid interval
- **THEN** the generated timer SHALL use that interval and SHALL reference only the
  generated scheduler service

#### Scenario: Missed periods are not persistent by default

- **WHEN** the user service was inactive during one or more timer periods and
  persistence is disabled
- **THEN** systemd SHALL not replay all missed periods on activation

### Requirement: Runtime credentials and state isolation

The module and generated units SHALL not embed provider credentials, secrets, or
machine-specific authentication configuration. Scheduler state SHALL remain in the
user state directory with private permissions.

#### Scenario: Provider authentication is unavailable

- **WHEN** `gh`, `tea`, Git, OpenSpec, OpenCode, or the implementor cannot
  authenticate or execute
- **THEN** the service SHALL report failure without writing substitute credentials
  or advancing state beyond the configured cursor policy

#### Scenario: State update is interrupted

- **WHEN** a process is interrupted while writing scheduler state
- **THEN** the state file SHALL remain either the previous complete record or the
  next complete record, never a partial record

### Requirement: Sceptre boundary

The generic repository scheduler SHALL use the existing GitHub/Gitea provider
operations rather than invoking Grimoire-specific Sceptre spec-set commands.

#### Scenario: Generic OpenSpec repository is scheduled

- **WHEN** a configured upstream is not represented by a Sceptre spec-set catalog
- **THEN** the scheduler SHALL use `gh` or `tea` through the implementor path and
  SHALL not call `sceptre specset next`, `materialize`, or `publish`

#### Scenario: Future Sceptre integration is added

- **WHEN** a future Sceptre release exposes a compatible generic repository
  operation
- **THEN** the scheduler's provider boundary SHALL allow that operation to be
  adopted without changing repository selection, locking, or cursor semantics

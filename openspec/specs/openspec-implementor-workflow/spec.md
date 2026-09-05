# openspec-implementor-workflow Specification

## Purpose
Provides one Home Manager-installed command for implementing an unfinished
OpenSpec change in an isolated branch and publishing the result as a GitHub or
Gitea pull request.

## Requirements

### Requirement: Public Home Manager module

The repository SHALL provide a Home Manager module under
`home-modules/project-manager/automated-development-workflows/implementor` and
export it through `homeModules` under a documented stable name.

#### Scenario: Module is disabled

- **WHEN** the module is imported with its enable option disabled
- **THEN** it SHALL install no implementor command and SHALL not create files
  or modify other OpenCode or project-manager configuration

#### Scenario: Module is enabled

- **WHEN** the module is enabled with its required runtime package options
- **THEN** it SHALL install an executable named `openspec-implementor`

### Requirement: Upstream repository input

The command SHALL accept an upstream Git repository URL and SHALL reject a
missing, malformed, or unsupported URL before cloning or invoking an agent.

#### Scenario: Valid upstream URL

- **WHEN** the command receives a valid GitHub or Gitea upstream URL
- **THEN** it SHALL derive the repository identity and continue with provider
  and default-branch resolution

#### Scenario: Unsupported provider

- **WHEN** the upstream URL does not identify GitHub or a configured Gitea
  provider and no explicit provider override is supplied
- **THEN** the command SHALL fail with an actionable provider error

### Requirement: OpenSpec change discovery

The command SHALL use OpenSpec JSON output to identify active changes and their
completion status rather than parsing task checkboxes as its primary status
mechanism.

#### Scenario: Eligible automatic change exists

- **WHEN** no explicit change is supplied and one or more active changes are
  incomplete
- **THEN** the command SHALL select one deterministic eligible change

#### Scenario: No eligible change exists

- **WHEN** no active incomplete change is available
- **THEN** the command SHALL exit successfully without cloning an implementation
  worktree or opening a pull request, and SHALL report that no work was found

#### Scenario: Explicit change is supplied

- **WHEN** `--change NAME` is supplied
- **THEN** the command SHALL operate only on that change and SHALL fail clearly
  if it is missing, archived, invalid, or ineligible

### Requirement: Agent selection

The command SHALL select an OpenCode agent from a recognized agent prefix in
the change name and SHALL use `developer` when no recognized prefix exists.

#### Scenario: Recognized agent prefix

- **WHEN** a change name begins with `<configured-agent>-`
- **THEN** the command SHALL invoke `opencode-agent` with that configured agent

#### Scenario: Unrecognized prefix

- **WHEN** the first hyphen-delimited component is not a configured agent name
- **THEN** the command SHALL invoke `opencode-agent` with `developer`

### Requirement: Isolated implementation worktree

The command SHALL clone or materialize the upstream repository into temporary
local state and SHALL create a branch named `feature/<change-name>` before
starting the implementation agent.

#### Scenario: Worktree is created

- **WHEN** an eligible change has no blocked pending pull request
- **THEN** the agent SHALL run in an isolated worktree on the expected feature
  branch, without modifying an existing user checkout

#### Scenario: Invalid branch name

- **WHEN** the change name cannot safely form a Git branch name
- **THEN** the command SHALL fail before starting the agent

### Requirement: Agent implementation contract

The command SHALL instruct the selected agent to implement the exact OpenSpec
change, run relevant validation, synchronize and archive the change when
implementation is complete, and refrain from committing, pushing, or opening a
pull request.

#### Scenario: Agent succeeds and archives

- **WHEN** the agent exits successfully and the selected change is archived
- **THEN** the command SHALL proceed to local verification and publication

#### Scenario: Agent fails or does not archive

- **WHEN** the agent exits unsuccessfully or the selected change remains active
- **THEN** the command SHALL not commit, push, or open a pull request

### Requirement: Pending pull-request skipping

The command SHALL skip active changes with an existing open, unmerged pull
request from `feature/<change-name>` unless `--force` is supplied.

#### Scenario: Automatic selection finds a pending pull request

- **WHEN** an automatically discovered change has a matching pending pull
  request
- **THEN** the command SHALL skip it and continue searching for another
  eligible change

#### Scenario: Explicit selection is pending

- **WHEN** an explicitly selected change has a matching pending pull request
  and `--force` is absent
- **THEN** the command SHALL fail without starting an agent

#### Scenario: Force is supplied

- **WHEN** `--force` is supplied for a change with a matching pending pull
  request
- **THEN** the command SHALL permit implementation to proceed but SHALL not
  create a duplicate pull request for the same branch

### Requirement: Commit and pull-request publication

After successful implementation and archival, the command SHALL verify the
worktree, commit the changes, push `feature/<change-name>`, and open one pull
request against the selected base branch using the appropriate provider CLI.

#### Scenario: GitHub publication

- **WHEN** the upstream is GitHub and the agent-produced worktree passes local
  checks
- **THEN** the command SHALL use `gh` to create or identify the pull request and
  SHALL report its URL

#### Scenario: Gitea publication

- **WHEN** the upstream is Gitea and the agent-produced worktree passes local
  checks
- **THEN** the command SHALL use `tea` to create or identify the pull request
  and SHALL report its URL

#### Scenario: Publication prerequisite fails

- **WHEN** archival, diff validation, commit, push, or pull-request creation
  fails
- **THEN** the command SHALL not claim success and SHALL report the failed stage

### Requirement: Cleanup and recovery

The command SHALL remove temporary repository and worktree state after
successful publication and SHALL support preserving failed state for diagnosis.

#### Scenario: Successful run

- **WHEN** the pull request is created successfully
- **THEN** the temporary worktree and clone SHALL be removed

#### Scenario: Preserve failed worktree

- **WHEN** `--keep-worktree` is supplied and a workflow stage fails
- **THEN** the command SHALL retain the temporary state and report its path

### Requirement: Credential and configuration isolation

The module and command SHALL not embed provider credentials, secret contents,
or machine-specific authentication configuration in the Nix store or generated
Home Manager files.

#### Scenario: Runtime authentication is absent

- **WHEN** Git, `gh`, `tea`, OpenSpec, or OpenCode authentication is unavailable
- **THEN** the command SHALL fail with an actionable runtime error without
  writing substitute credentials or exposing secret contents

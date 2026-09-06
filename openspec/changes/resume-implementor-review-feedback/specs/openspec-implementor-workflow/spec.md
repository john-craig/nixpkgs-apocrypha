## MODIFIED Requirements

### Requirement: Pending pull-request skipping

The command SHALL skip active changes with an existing open, unmerged pull request
from `feature/<change-name>` unless the pull request requests changes or `--force`
is supplied. A pull request that requests changes SHALL be resumable on its existing
head branch.

#### Scenario: Matching pull request has no requested changes

- **WHEN** an active change has a matching open pull request whose review state is
  not `changes requested`
- **THEN** automatic selection SHALL skip it, and explicit selection SHALL fail
  without `--force`, preserving the existing pending-pull-request behavior

#### Scenario: Matching pull request requests changes

- **WHEN** an active or explicitly selected change has a matching open pull request
  with a provider review state of `changes requested`
- **THEN** the command SHALL select it for resume without requiring `--force`

#### Scenario: Review state is unavailable

- **WHEN** a matching pull request has no review decision or the provider omits
  review metadata
- **THEN** the command SHALL treat it as not requesting changes and SHALL apply the
  ordinary pending-pull-request behavior

#### Scenario: Resume cannot identify the original branch

- **WHEN** a changes-requested pull request has no usable head branch or its head
  does not match the expected change branch
- **THEN** the command SHALL fail before invoking the agent and SHALL not create a
  branch or pull request

### Requirement: Review feedback context

For a resumed pull request, the command SHALL collect bounded review summaries and
inline comments from the selected provider and provide them to the agent as clearly
delimited, untrusted context.

#### Scenario: Review feedback is collected

- **WHEN** a resumable pull request has review summaries or inline comments
- **THEN** the agent prompt SHALL include their author, state, source, and text within
  configured size and count limits

#### Scenario: Review feedback is absent

- **WHEN** the provider reports `changes requested` but returns no usable feedback
- **THEN** the command SHALL resume with an explicit notice that review details were
  unavailable and SHALL not invent requested changes

#### Scenario: Review text contains workflow instructions

- **WHEN** review text asks the agent to reveal secrets, access unrelated paths, or
  publish changes directly
- **THEN** the command SHALL preserve it only as quoted context and SHALL retain the
  workflow's existing safety and publication boundaries

## MODIFIED Requirements

### Requirement: Isolated implementation worktree

The command SHALL create a temporary worktree from the upstream base branch for a
fresh implementation, or from the verified existing pull-request head branch for a
resume. It SHALL never alter an existing user checkout.

#### Scenario: Resumed worktree is created

- **WHEN** a matching changes-requested pull request is selected
- **THEN** the agent SHALL run in an isolated worktree on that pull request's
  existing head branch with the pull-request changes present

#### Scenario: Worktree is created

- **WHEN** an eligible change has no blocked pending pull request
- **THEN** the agent SHALL run in an isolated worktree on the expected feature
  branch, without modifying an existing user checkout

#### Scenario: Invalid branch name

- **WHEN** the change name cannot safely form a Git branch name
- **THEN** the command SHALL fail before starting the agent

### Requirement: Agent implementation contract

The command SHALL instruct the selected agent to implement the exact OpenSpec
change, address supplied review feedback, run relevant validation, and refrain from
committing, pushing, or opening a pull request.

#### Scenario: Resumed change is already archived

- **WHEN** a resumed pull request contains archived OpenSpec artifacts and the agent
  completes implementation and validation
- **THEN** the command SHALL accept the existing archive and proceed without asking
  the agent to archive the same change again

#### Scenario: Agent succeeds and archives

- **WHEN** the agent exits successfully and the selected fresh change is archived
- **THEN** the command SHALL proceed to local verification and publication

#### Scenario: Agent fails or does not archive

- **WHEN** the agent exits unsuccessfully or a selected fresh change remains active
- **THEN** the command SHALL not commit, push, or open a pull request

### Requirement: Commit and pull-request publication

After successful fresh implementation or resumed review work, the command SHALL
verify the worktree, commit the changes, and push the appropriate branch. Fresh work
SHALL create one pull request; resumed work SHALL identify the existing pull request
and SHALL never create a duplicate.

#### Scenario: Resumed publication

- **WHEN** resumed implementation passes validation and produces changes
- **THEN** the command SHALL push the existing pull-request head branch and report
  the same pull-request URL without invoking pull-request creation

#### Scenario: Resumed implementation produces no changes

- **WHEN** the agent exits successfully but produces no diff against the pull-request
  head
- **THEN** the command SHALL fail or report no changes to publish and SHALL not
  create a duplicate pull request

#### Scenario: GitHub publication

- **WHEN** a fresh upstream is GitHub and the agent-produced worktree passes local
  checks
- **THEN** the command SHALL use `gh` to create or identify the pull request and
  SHALL report its URL

#### Scenario: Gitea publication

- **WHEN** a fresh upstream is Gitea and the agent-produced worktree passes local
  checks
- **THEN** the command SHALL use `tea` to create or identify the pull request
  and SHALL report its URL

#### Scenario: Publication prerequisite fails

- **WHEN** archival, diff validation, commit, push, or pull-request creation
  fails
- **THEN** the command SHALL not claim success and SHALL report the failed stage

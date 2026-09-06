## Why

The implementor currently treats every open pull request for a selected change as
blocked. When review requests changes, the operator must manually reconstruct the
implementation context and invoke another workflow, while the existing branch,
pull request, and review feedback are already the correct continuation point.

## What Changes

- Detect whether a matching open pull request has a provider review state that
  requests changes.
- Resume implementation on the existing pull-request head branch instead of
  creating a new branch or duplicate pull request.
- Collect bounded review summaries and inline comments from GitHub or Gitea and
  provide them to the implementation agent as untrusted review context.
- Preserve the current skip, explicit-selection, and `--force` behavior for open
  pull requests that do not request changes.
- Add provider, worktree, prompt, publication, and failure-path tests.

## Capabilities

### New Capabilities

- `implementor-review-feedback-resume`: Continue an existing implementor pull
  request when reviewers request changes.

## Impact

- Extends provider pull-request adapters and selection logic in the implementor
  workflow.
- Adds a resume worktree path that fetches and checks out the existing pull-request
  head branch.
- Changes the agent contract for resumed work so an already archived OpenSpec
  change does not need to be archived a second time.
- Reuses the existing publication path to commit and push the same branch while
  never creating a duplicate pull request.
- Requires bounded handling of review text because provider comments are external,
  potentially stale, and untrusted input.

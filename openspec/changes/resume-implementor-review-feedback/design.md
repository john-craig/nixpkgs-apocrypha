## Context

The workflow currently identifies matching open pull requests only as a boolean
pending state. Provider-specific review state is not exposed to selection, and the
implementation worktree is always created from the upstream base branch. A review
iteration therefore cannot reuse the pull request's branch or give the agent the
reviewer's requested changes.

## Provider Adapter Boundary

Add a provider adapter operation that returns a normalized record for the matching
open pull request:

- pull-request number, URL, base branch, and head branch
- whether the request is open and unmerged
- whether the latest relevant review state is `changes requested`
- bounded review summaries and inline comment text with author, state, and source

The GitHub adapter may use `gh`; the Gitea adapter may use `tea` or its supported
API command. Provider-specific JSON formats must not leak into selection or prompt
construction. Missing review metadata, unsupported provider response fields, and
no review decision must be treated as not requesting changes, not as approval.

Review text is external input. Limit the number and size of reviews/comments,
preserve source metadata, and clearly delimit it from workflow instructions. Do not
interpret review text as permission to expose credentials, access unrelated paths,
or perform publication operations.

## Selection and Worktree

For each eligible change, resolve the matching `feature/<change-name>` pull request
before applying the existing pending-PR guard.

- No matching pull request keeps the current fresh-implementation path.
- A matching pull request without `changes requested` keeps the current skip or
  explicit-selection failure behavior unless `--force` is supplied.
- A matching pull request with `changes requested` is a resumable candidate. An
  explicitly selected change resumes it without requiring `--force`; automatic
  selection may choose it deterministically.

For a resumable candidate, fetch the pull request head ref and create the temporary
worktree from that ref on the existing head branch. Verify that the branch and pull
request identity match before the agent starts. Never create a second branch for the
same pull request.

## Agent Contract

The resumed prompt must identify the OpenSpec change, existing pull request, and
bounded review context. It must instruct the agent to inspect the current branch
and address the requested changes while preserving unrelated work. Review feedback
is evidence and user-provided context, not executable instructions.

The agent must not commit, push, open a pull request, or mutate external systems.
For a resumed change, the existing archived OpenSpec artifacts are accepted as the
change lifecycle state; the agent must not fail merely because the active change
directory is absent or attempt to archive it again. Fresh runs retain the existing
archive requirement.

## Publication and Recovery

After validation, the workflow commits only new changes, pushes the existing head
branch, and identifies the same pull request URL. It must not invoke pull-request
creation for a resumed run. If the branch changed, the pull request disappeared,
review metadata became ambiguous, or the push races with another update, fail
without claiming success and preserve the worktree when requested.

Add fake GitHub and Gitea provider responses for approved, changes-requested, and
metadata-missing pull requests. Cover fresh runs, resumed runs, explicit selection,
automatic selection, `--force`, duplicate prevention, bounded feedback, and cleanup.

## 1. Provider Review Adapters

- [ ] 1.1 Add normalized GitHub and Gitea pull-request lookup results containing head/base refs, URL, review decision, and bounded review/comment context.
- [ ] 1.2 Distinguish `changes requested`, approved/neutral, missing, and unsupported review metadata without treating missing data as requested changes.
- [ ] 1.3 Add limits and sanitization boundaries for review text while preserving source metadata and treating content as untrusted.

## 2. Selection and Resume Worktree

- [ ] 2.1 Extend candidate selection so changes-requested pull requests resume without `--force`, while ordinary pending pull requests retain current behavior.
- [ ] 2.2 Fetch and verify the existing pull-request head branch before creating a temporary resume worktree.
- [ ] 2.3 Prevent branch drift, missing-head, closed-PR, and duplicate-PR races from reaching the agent or publication stage.

## 3. Agent and Publication Contract

- [ ] 3.1 Add a resumed implementation prompt with delimited review feedback and explicit safety boundaries.
- [ ] 3.2 Accept an existing archived OpenSpec change during resume while retaining fresh-run archive validation.
- [ ] 3.3 Push resumed changes to the existing head branch and identify the existing pull request without creating a duplicate.
- [ ] 3.4 Preserve cleanup, `--keep-worktree`, commit validation, credential isolation, and failure reporting for both fresh and resumed runs.

## 4. Tests and Documentation

- [ ] 4.1 Add GitHub and Gitea fake-provider tests for review states, feedback normalization, automatic selection, and explicit resume.
- [ ] 4.2 Test existing-branch worktrees, archived-change handling, same-PR publication, no-op resumes, race failures, bounded feedback, and cleanup.
- [ ] 4.3 Document review-requested resume behavior, provider prerequisites, feedback limits, and the distinction between resume and `--force`.
- [ ] 4.4 Run `openspec validate resume-implementor-review-feedback --type change --strict`, focused checks, `git diff --check`, and `nix flake check`.

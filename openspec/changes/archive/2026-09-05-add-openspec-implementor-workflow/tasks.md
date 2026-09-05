## 1. Module and Runtime Interface

- [x] 1.1 Add the `project-manager/automated-development-workflows/implementor` Home Manager module and export it from `home-modules/default.nix` under a documented stable name.
- [x] 1.2 Define enable, package override, provider, base-branch, work-root, and cleanup options using the repository's existing typed option and assertion patterns.
- [x] 1.3 Install exactly one `openspec-implementor` command when enabled and verify disabled evaluation installs no command or unrelated files.
- [x] 1.4 Validate required runtime executables and report actionable errors for missing Git, OpenSpec, OpenCode runner, or selected provider CLI.

## 2. Change Selection and Agent Execution

- [x] 2.1 Implement upstream URL validation, provider inference, repository identity normalization, and default-branch resolution.
- [x] 2.2 Clone the upstream into temporary state, enumerate active changes with `openspec list --json`, and determine eligibility with `openspec status --change NAME --json`.
- [x] 2.3 Implement deterministic automatic selection and explicit `--change` validation, including no-work and invalid-change outcomes.
- [x] 2.4 Implement recognized agent-prefix resolution with `developer` fallback and validate the selected agent before invocation.
- [x] 2.5 Create `feature/<change-name>` in an isolated worktree and invoke the existing `opencode-agent` runner with the exact change-specific implementation prompt.
- [x] 2.6 Verify agent success and archived-change state before allowing any commit or publication operation.

## 3. Provider and Publication Workflow

- [x] 3.1 Implement provider adapters for pending pull-request lookup, using `gh` for GitHub and `tea` for Gitea.
- [x] 3.2 Skip matching pending pull requests during automatic selection and reject explicit pending changes unless `--force` is supplied.
- [x] 3.3 Recheck branch and pull-request idempotency immediately before publication so `--force` cannot create duplicate pull requests.
- [x] 3.4 Verify the expected branch, run `git diff --check`, commit agent changes with a deterministic message, and push the feature branch.
- [x] 3.5 Create or identify the provider pull request with bounded title and description content and report the resulting URL.
- [x] 3.6 Keep the generic implementation independent of Sceptre's Grimoire-specific `specset publish` interface.

## 4. Cleanup, Security, and Failure Handling

- [x] 4.1 Add cleanup traps for temporary clones and worktrees, preserving failed state and reporting its path when `--keep-worktree` is supplied.
- [x] 4.2 Ensure failures in agent execution, archive verification, diff checking, commit, push, or PR creation stop later stages and return non-zero status.
- [x] 4.3 Ensure provider credentials, authentication files, local paths, and secret contents are never copied into generated files, command output, commits, or the Nix store.

## 5. Tests and Documentation

- [x] 5.1 Add fake-command and local-repository tests for URL validation, change status fixtures, explicit selection, deterministic selection, and no-work behavior.
- [x] 5.2 Add tests for agent-prefix selection, developer fallback, worktree branch creation, exact OpenCode runner arguments, and archive gating.
- [x] 5.3 Add GitHub and Gitea provider adapter tests covering pending PR skip, `--force`, duplicate prevention, push, and PR creation.
- [x] 5.4 Add cleanup and failure-recovery tests, including `--keep-worktree` and absence of secret material in generated outputs.
- [x] 5.5 Document module configuration, runtime authentication, command examples, flags, provider behavior, Sceptre limitations, and recovery procedures in the automated workflow README.
- [x] 5.6 Run `git diff --check`, `openspec validate add-openspec-implementor-workflow --type change --strict`, focused checks, and `nix flake check`.

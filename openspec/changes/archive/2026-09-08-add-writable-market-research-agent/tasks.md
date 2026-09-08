## 1. Agent Definition

- [x] 1.1 Add a shared `market-research` skill covering intake, staged research, evidence ledgers, source triangulation, uncertainty labels, synthesis, quality review, and bounded local writes; verify the generated skill text contains the write boundary and secret-safety rules
- [x] 1.2 Update the existing `market-researcher` role to select the new skill and allow local artifact edits while retaining read-only external research and approval-gated shell behavior; verify generated JSON reflects the intended permissions
- [x] 1.3 Preserve existing source-integrity, evidence, authentication, and MCP declarations; verify the role continues to use unauthenticated web research without embedding credentials

## 2. Artifact Contract

- [x] 2.1 Define and document the local research output convention for scope, plan, evidence ledger, findings, and final report artifacts; verify an example output layout is clear and stable
- [x] 2.2 Define refresh and supersession behavior for existing reports, including research date, changed claims, assumptions, and unresolved limitations; verify the documentation distinguishes new evidence from prior conclusions
- [x] 2.3 Add instructions preventing external publishing, repository mutation, credential changes, and unrelated project writes; verify the role prompt and skill state the external-mutation boundary

## 3. Verification and Documentation

- [x] 3.1 Extend `tests/opencode-agents.nix` to verify market-research skill materialization, writable edit permission, read/list behavior, MCP isolation, and secret/path safety; verify `nix build .#checks.x86_64-linux.opencode-agents` passes
- [x] 3.2 Add a generated-configuration test showing a consumer can override `market-researcher` back to read-only; verify the explicit override wins over the new default
- [x] 3.3 Update `docs/opencode-agents.md` with the writable boundary, artifact workflow, output-location guidance, public skill references, and read-only override example; verify documented names and paths match generated configuration
- [x] 3.4 Run formatting and the complete flake check suite; verify `nix flake check` passes without modifying unrelated worktree files

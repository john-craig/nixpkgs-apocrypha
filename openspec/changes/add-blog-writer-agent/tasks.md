## 1. Agent Definition

- [ ] 1.1 Add the named `blog-writer` environment in `home-modules/opencode-agents/definitions.nix` with repository content editing enabled, web research explicitly declared, and no publishing or external-write integration; verify the generated environment has the expected model, prompt, permissions, and MCP isolation.
- [ ] 1.2 Add a reusable writing skill or rule covering conversational, concrete, restrained, desloppified prose, minimum-edit revisions, preservation of intentional voice, and the prohibition on detector-evasion claims; verify unrelated agents retain their existing shared content unchanged.
- [ ] 1.3 Add the staged editorial workflow and source-integrity rules covering brief, research, outline, drafting, fact review, voice review, revision, packaging, `[SOURCE NEEDED]`, and `[AUTHOR INPUT NEEDED]`; verify generated role-local instructions contain each required stage and marker.
- [ ] 1.4 Configure write behavior so the agent can create or update authorized content files in the selected repository while deletion, commit, push, publication, and external mutations remain denied or approval-gated; verify the permission map and prompt boundary agree.

## 2. Generated Configuration Tests

- [ ] 2.1 Extend `tests/opencode-agents.nix` to materialize `blog-writer` and verify its generated JSON, prompt, selected skills/rules, model, file-edit permission, and research capability.
- [ ] 2.2 Add assertions for write-boundary behavior, MCP isolation, denied secret access, and absence of unintended credentials; verify generated configuration contains no publishing service or external write integration.
- [ ] 2.3 Add preservation and content-policy fixtures for links, citations, quotes, code, numbers, front matter, uncertainty, author voice, `[SOURCE NEEDED]`, and `[AUTHOR INPUT NEEDED]`; verify the expected protections are represented in the generated instructions.
- [ ] 2.4 Add runner or integration checks showing an authorized content path can be edited while an ambiguous/out-of-scope target and publication/commit operation require refusal or approval; verify unrelated runner tests still pass.

## 3. Documentation

- [ ] 3.1 Add `blog-writer` to the role inventory and environment mapping in `docs/opencode-agents.md`, including a write-enabled invocation example and target-path authorization requirement; verify the documented generated path matches the role name.
- [ ] 3.2 Document the editorial stages, desloppified style guidance, source and author-input markers, preservation rules, and explicit non-goals of publishing, committing, and external posting; verify documentation matches the generated prompt and permissions.

## 4. Verification

- [ ] 4.1 Add the new role to any explicit generated-agent list in `flake.nix` and run the focused Nix/OpenCode agent check; verify all existing agent checks continue to pass.
- [ ] 4.2 Run formatting and strict OpenSpec validation, then inspect generated JSON and the final diff for accidental credentials, broad destructive permissions, external publishing behavior, or changes outside the approved scope; verify the change is ready for implementation.

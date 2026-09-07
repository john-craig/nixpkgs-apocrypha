## 1. Agent Definition

- [ ] 1.1 Add the named `nutritionist` environment in `home-modules/opencode-agents/definitions.nix` with a concise role prompt covering education, recipe research, conditional planning, clinician referral, and no medical claims; verify the generated role has the expected name and description.
- [ ] 1.2 Add or compose the nutrition-specific safety, evidence, privacy, and read-only instructions without mutating shared behavior for unrelated agents; verify existing shared skills and rules remain unchanged in generated configurations.
- [ ] 1.3 Configure only explicitly available read-only research integrations, with no credentials or write-capable services; verify the generated nutritionist configuration contains no unintended MCP inheritance or secret contents.

## 2. Generated Configuration Tests

- [ ] 2.1 Extend `tests/opencode-agents.nix` to materialize the nutritionist environment and verify its model, prompt, selected skills/rules, and default read-only permissions.
- [ ] 2.2 Add assertions for nutritionist isolation, unavailable integrations, and denied mutation or secret access; verify the Nix test derivation passes with `nix build .#checks.x86_64-linux.opencode-agents` or the repository's equivalent check target.
- [ ] 2.3 Add behavior-oriented fixtures or prompt checks for education, incomplete intake, passed screening, high-risk referral, emergency referral, and evidence uncertainty; verify each expected outcome is represented without requiring external writes.

## 3. Documentation

- [ ] 3.1 Document the `nutritionist` role, invocation path, supported request types, and read-only boundary in `docs/opencode-agents.md`; verify the generated documentation names the role and explains the safety-screen distinction.
- [ ] 3.2 Document authoritative-source expectations and the limitation that an unconfigured food or recipe service must not be claimed as operational; verify the documentation matches the generated MCP configuration.

## 4. Verification

- [ ] 4.1 Run formatting, evaluation, and focused OpenCode-agent checks for the changed Nix, test, and documentation files; verify existing unrelated agent checks still pass.
- [ ] 4.2 Inspect the final generated JSON and git diff for accidental credentials, external-write permissions, persistence additions, or changes outside the approved scope; verify only the nutritionist change and intended test/documentation updates are present.

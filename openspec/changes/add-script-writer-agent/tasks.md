## 1. Agent Definition

- [ ] 1.1 Add the named `script-writer` environment in `home-modules/opencode-agents/definitions.nix` with explicit short-form and long-form adaptation guidance; verify the generated role has the expected name, model, description, and prompt.
- [ ] 1.2 Add reusable script-writing guidance covering hooks, beats, pacing, narrative arcs, narration, visuals, on-screen text, sound cues, timing, and source notes; verify the role-local skill is materialized with both format routes.
- [ ] 1.3 Compose `source-integrity` and `evidence` behavior for preserving citations, quotations, uncertainty, author voice, `[SOURCE NEEDED]`, and `[AUTHOR INPUT NEEDED]`; verify embedded source instructions are treated as untrusted content.
- [ ] 1.4 Enable repository content-file creation and updates for explicitly authorized targets while keeping shell operations approval-gated and publication, commit, push, unrelated deletion, and external mutations unavailable or approval-gated; verify the generated permission map reflects this boundary.
- [ ] 1.5 Audit and adapt `bradtraversy/editorial-workflow`, `bnivanov/omp-writing-skills`, `ehmo/slopkit`, and `conorbronsdon/avoid-ai-writing` patterns for the role without copying unlicensed or unnecessary prompt, corpus, or detector material; verify the implementation retains required MIT and third-party attribution notices where applicable.

## 2. Generated Configuration Tests

- [ ] 2.1 Extend `tests/opencode-agents.nix` to materialize `script-writer` and verify its model, prompt, selected skills/rules, edit permission, and declared research MCPs.
- [ ] 2.2 Add assertions for short-form and long-form guidance, separated production tracks, source markers, write authorization, MCP isolation, and secret non-leakage; verify the focused OpenCode-agent check passes.
- [ ] 2.3 Add runner coverage showing the named environment resolves correctly and continues to enforce target-directory and prompt validation; verify existing agent runner behavior is unchanged.
- [ ] 2.4 Add checks for preservation of links, numbers, headings, code, tables, quotations, front matter, and intentional voice, and verify style or detector signals are not treated as authorship proof.

## 3. Flake and Documentation

- [ ] 3.1 Add `script-writer` to the explicit generated-agent inventory in `flake.nix`; verify the flake check finds its JSON and prompt files.
- [ ] 3.2 Document the role inventory, generated path, short-form and long-form behavior, write authorization requirement, and publication boundary in `docs/opencode-agents.md`; verify the invocation example targets a repository content file.

## 4. Verification

- [ ] 4.1 Run formatting, focused Nix/OpenCode-agent checks, and flake evaluation; verify all existing checks continue to pass.
- [ ] 4.2 Inspect generated JSON, generated skill text, and the final git diff for broad destructive permissions, accidental credentials, external publishing behavior, or changes outside the approved scope; verify the implementation handoff is complete.
- [ ] 4.3 Review any reused upstream material and notices against the four referenced repositories' licenses and attribution files; verify no third-party corpus or detector logic is included without its required notice.

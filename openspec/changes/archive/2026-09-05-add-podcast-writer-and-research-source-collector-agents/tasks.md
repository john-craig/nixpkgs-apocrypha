## 1. Agent Definitions and Skills

- [x] 1.1 Add the named `podcast-writer` environment with corpus-scoped educational scripting guidance; verify its generated model, prompt, description, skills, and writable-output policy.
- [x] 1.2 Add the named `research-source-collector` environment with recent/historical source-collection guidance; verify its generated model, prompt, description, skills, and approved public-research policy.
- [x] 1.3 Add focused `podcast-writing` and `research-source-collection` skills covering structured outputs, speaker turns, citations, source provenance, chronology, freshness, contradictions, uncertainty, and limitations; verify each skill materializes only for its declared role.
- [x] 1.4 Add shared untrusted-content, no-secrets, isolation, and bounded-output guidance; verify prompts treat corpus/web instructions as data rather than authorization.

## 2. Permissions and Capability Boundaries

- [x] 2.1 Configure the podcast writer to read only supplied corpus material and write only an authorized structured output directory; verify browsing, unrelated file access, shell execution, publishing, TTS, and external writes are denied or unavailable by default.
- [x] 2.2 Configure the source collector for approved public search/fetch adapters with bounded result, timeout, response, and workspace limits; verify private files, credentials, transcript generation, and external writes are denied or unavailable.
- [x] 2.3 Ensure the two roles do not inherit each other's tools, prompts, or MCP servers; verify generated environments contain only explicitly declared capabilities and no secrets or machine-specific paths.

## 3. Tests and Documentation

- [x] 3.1 Extend `tests/opencode-agents.nix` for both generated roles, prompts, focused skills, models, permissions, isolation, secret safety, and structured-output boundaries; verify the focused check passes.
- [x] 3.2 Add fixture assertions for podcast multi-segment/multi-turn structure, per-segment citations or uncertainty markers, corpus-only behavior, and rejection of transcript output from the research role; verify invalid contracts fail clearly.
- [x] 3.3 Add fixture assertions for recent/historical research metadata, canonical URL deduplication, hashes, failed-source handling, contradictions, gaps, and unavailable-adapter behavior; verify claims require observable evidence.
- [x] 3.4 Extend `flake.nix` runner inventory and runner tests for both agent names, target-directory validation, prompt preservation, and absence of implicit `--auto`; verify existing agents remain unchanged.
- [x] 3.5 Document the two roles, reference-project boundaries, corpus/workspace inputs, public-web adapter prerequisites, output contracts, provenance requirements, and non-goals in `docs/opencode-agents.md`; verify docs do not claim hosted or private-data capabilities.

## 4. Verification and Handoff

- [x] 4.1 Run formatting, focused OpenCode-agent checks, full flake evaluation, and `openspec validate --specs`; verify all existing checks pass.
- [x] 4.2 Inspect generated JSON, prompts, skills, permissions, MCP declarations, and final diff for broad access, credential leakage, unbounded browsing/execution, transcript/research boundary violations, and unrelated changes; verify the implementation handoff is complete.

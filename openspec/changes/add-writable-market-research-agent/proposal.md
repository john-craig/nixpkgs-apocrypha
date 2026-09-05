## Why

The existing `market-researcher` environment is limited to read-only research,
although useful research requires preserving source ledgers, structured findings,
and reports for later review. The agent should be able to write bounded local
research artifacts while keeping external systems, credentials, and unrelated
project files protected.

## What Changes

- Enable the existing market-researcher role to create and update local research artifacts and reports.
- Add a repository-managed market-research skill based on public patterns for market context, staged research, evidence ledgers, triangulation, synthesis, and quality review.
- Preserve read-only access to external research sources and prohibit mutations to external services or source systems.
- Require explicit output locations, provenance metadata, uncertainty labels, and source-quality checks for written research.
- Retain secret redaction, untrusted-content handling, and bounded-output requirements.
- Extend generated-agent tests and documentation for writable artifacts, permissions, output conventions, and safe failure behavior.

## Capabilities

### New Capabilities

- `market-research-agent`: A writable, evidence-backed market-research workflow that produces auditable local research artifacts without mutating external systems.

### Modified Capabilities

None.

## Impact

- `home-modules/opencode-agents/definitions.nix` for the market-research skill, role permissions, and role prompt.
- `tests/opencode-agents.nix` for generated skill, writable permission, isolation, and secret-safety coverage.
- `docs/opencode-agents.md` for the role's write boundary, output conventions, and public research references.
- Existing users of `market-researcher` will gain local file-write authority; users requiring the previous read-only behavior must override its permissions explicitly.
- External research services remain read-only runtime dependencies and no new credentials are embedded in generated configuration.

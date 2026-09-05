## Why

The personalized-study-podcasts project already separates source collection from transcript
generation, but the repository lacks reusable OpenCode roles that preserve those boundaries.
Two focused agents would make the workflow portable: one turns an approved corpus into a
validated educational podcast script, while the other gathers bounded, cited public sources
without producing a transcript or accessing private project data.

## What Changes

- Add a `podcast-writer` agent for source-grounded educational podcast planning and structured
  two-host transcript generation.
- Add a `research-source-collector` agent for recent or historical public-web research,
  source selection, fetching, provenance recording, and limitation reporting.
- Add role-local skills and policies for corpus boundaries, citation requirements, uncertainty,
  untrusted content, bounded output, and separation between research and writing.
- Keep podcast writing offline and corpus-scoped; keep source collection limited to approved
  public search/fetch adapters and structured source-selection output.
- Add generated-agent tests, runner/inventory coverage, documentation, and secret/path leakage
  checks.

## Capabilities

### New Capabilities

- `podcast-writer-agent`: Source-grounded educational podcast script generation with validated
  speaker turns, segment citations, uncertainty handling, and no unrelated browsing.
- `research-source-collector-agent`: Bounded recent or historical public-source collection
  with canonical URLs, dates, hashes, failures, contradictions, and structured manifests.

### Modified Capabilities

- `opencode-agent-environments`: Add stable `podcast-writer` and
  `research-source-collector` environments with isolated role content, explicit tools, and
  conservative permissions.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the two roles, focused skills, and
  role-specific MCP/tool declarations if required by the implementation.
- `tests/opencode-agents.nix`, `flake.nix`, and `docs/opencode-agents.md` gain generated-role,
  isolation, prompt, permission, runner, and inventory coverage.
- Runtime consumers still provide OpenCode, provider authentication, and any approved public
  search/fetch adapters; no hosted inference, private-file access, publishing, or persistent
  credentials are added by default.
- The source project remains the behavioral reference, not a source for copying prompts,
  private corpora, credentials, generated audio, or application implementation code.

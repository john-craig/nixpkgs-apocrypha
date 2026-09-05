## Context

The reference project defines separate OpenCode agents named `research` and `transcript`,
with distinct prompts, permissions, runner inputs, and output contracts. Research uses
approved public search/fetch adapters and writes bounded provenance manifests; transcript
generation receives corpus chunks and writes validated educational episode JSON. See
`proposal.md` and the delta specs for the behavior being introduced.

## Goals / Non-Goals

**Goals:**

- Represent the two reference roles as isolated repository-configured environments.
- Preserve the research-to-corpus-to-podcast boundary and structured output contracts.
- Make provenance, citations, uncertainty, untrusted content, and bounded operation behavior
  explicit in prompts, skills, tests, and documentation.
- Reuse the existing agent module's generated files and runner rather than adding a second
  configuration system.

**Non-Goals:**

- Running the Python application, TTS, browser player, or local HTTP service from the agent
  definition.
- Adding hosted search, hosted inference, publishing, audio generation, or database access.
- Copying source-project prompts, private corpus contents, generated audio, credentials, or
  application code into this repository.

## Decisions

### Use two separate roles

Create `podcast-writer` and `research-source-collector` rather than one general media agent.
The reference project intentionally denies browsing to transcript generation and denies
transcript output to research. Separate roles make those boundaries testable and prevent
capability drift.

### Use focused role-local skills

Add concise `podcast-writing` and `research-source-collection` skills containing the output
schemas, workflow checks, and safety policies. Do not copy the reference project's Python
implementation or its generated/sample corpus. Shared evidence, no-secrets, and isolation
rules remain selected explicitly.

### Keep research adapters consumer-provided

The research role may declare approved public web tools only if the existing OpenCode MCP
configuration can represent them without credentials or broad inheritance. Runtime adapters,
timeouts, limits, and provider authentication remain consumer supplied. If an adapter is
missing, the prompt requires a non-operational result rather than model-memory research.

### Permit structured local output only

The podcast role can write an authorized structured draft/output file if the implementation
needs writable permissions; it cannot publish, synthesize, or call external systems. The
research role can write source files and manifests only under its authorized output directory.
Both roles deny arbitrary shell execution and unrelated project access by default.

### Test boundaries rather than live providers

Nix tests will inspect generated JSON, prompts, skill materialization, permissions, isolation,
and prompt preservation through the existing fake runner. They will not invoke public search,
fetch providers, TTS, or the reference application's database. Fixture assertions will verify
required fields and rejection language without embedding real source content or credentials.

## Risks / Trade-offs

- **Research coverage is incomplete or stale** → record dates, hashes, failures, contradictions,
  and limitations; never present public-web coverage as exhaustive.
- **Source text can contain prompt injection** → treat all retrieved material as untrusted data
  and keep authorization in the role policy.
- **Podcast prose can overstate evidence** → require per-segment citations or uncertainty and
  validate structured episode shape before downstream use.
- **A generic MCP permission model cannot classify every tool operation** → keep research tools
  narrowly declared, deny unrelated capabilities, and require approval for any external write
  or capability expansion.
- **Reference behavior may evolve** → document the source project as behavioral provenance and
  keep the role contracts versioned in OpenSpec.

## Migration Plan

1. Add the two roles alongside existing environments; existing defaults remain unchanged.
2. Add generated-role tests, runner inventory entries, and documentation.
3. Consumers provide approved research adapters and output directories at runtime.
4. Rollback consists of removing the two roles and associated files; no source-project data is
   migrated.

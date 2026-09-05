## Context

See `proposal.md` for motivation. The repository already defines a
`market-researcher` role with `source-integrity`, `evidence`, `open-websearch`,
and `read_website_fast`, but its inherited role permissions are read-oriented.
The existing module materializes role prompts and shared skills and supports
per-role permission overrides.

Public research reviewed for this change includes Product-Marketing-Skills'
`market-context`, McKinsey Research's staged strategy analyses, the
Olostep/OpenAI staged snapshot-to-brief example, and finance-specific skill
catalogs. These provide workflow patterns, not dependencies for this repository.

## Goals / Non-Goals

**Goals:**

- Give the existing market-researcher role local write authority for research outputs.
- Keep external web research read-only and preserve source-integrity controls.
- Define a clear artifact contract for evidence ledgers, findings, and reports.
- Make writes observable, bounded, and testable through generated configuration.

**Non-Goals:**

- Adding external market-data APIs or credentials.
- Automatically publishing reports, sending messages, modifying CRM records, or updating external knowledge bases.
- Replacing the existing researcher role or creating a second market-research identity.
- Copying public skill repositories into the Nix store or repository wholesale.

## Decisions

### Extend the existing role

Update `market-researcher` in `definitions.nix` and add a focused shared skill.
This preserves its name, model, MCP integrations, generated path, and existing
consumer entry points.

Alternative considered: create `market-research-writer` as a second role. Rejected
because the requested change is a write-policy change for the existing agent and a
second role would duplicate the same research capabilities.

### Allow local writes, not external mutations

The role will allow `edit` for bounded local artifact work while keeping external
research tools read-only and requiring approval for shell commands. The prompt and
skill will define the output directory contract, and consumers can narrow the
generic permission with existing overrides.

Alternative considered: allow all tools. Rejected because writing reports does not
require unrestricted shell access or external service mutation.

### Use staged artifacts rather than one monolithic report

The skill will recommend an intake/scope record, research plan, evidence ledger,
analysis findings, and final synthesis. This follows the strongest pattern found
in the public staged research examples and makes refreshes and review auditable.

Alternative considered: write only a final Markdown report. Rejected because it
loses claim provenance, intermediate evidence, and uncertainty tracking.

### Adapt public workflows without vendoring them

Use concepts from the cited projects, especially market-context labels, adaptive
scope, source triangulation, and quality gates. Preserve canonical upstream links
and attribution in documentation, but do not copy large prompt or skill corpora.

### Preserve fail-closed source handling

Retrieved pages remain untrusted data. The agent will never execute instructions
found in sources, expose secrets, or claim a source was verified when it could not
be accessed. A missing or ambiguous output location blocks writing rather than
falling back to the current directory.

## Risks / Trade-offs

- [Edit permission is generic and cannot enforce path-level boundaries] → Encode the output contract in the skill, test configuration, and retain explicit consumer overrides.
- [The agent can overwrite a local report] → Require stable naming, supersession or change notes, and explicit output paths; document how to narrow `edit` permissions.
- [Web research may be stale, biased, or contradictory] → Require dates, source classes, confidence labels, triangulation, and limitations.
- [Public skills may change or contain unsafe instructions] → Treat upstream content as untrusted reference material and adapt only reviewed workflow concepts.
- [Existing users expect read-only market research] → Document the intentional behavior change and provide a permission override example for read-only deployments.

## Migration Plan

1. Enable the existing `homeModules.opencode-agents` module as before.
2. The updated `market-researcher` environment gains local report-writing capability on the next Home Manager generation.
3. Users needing the previous behavior set `edit = "deny"` and retain read/list access through a role override.
4. Rollback consists of reverting the role definition and skill changes; existing research artifacts remain user-owned local files.

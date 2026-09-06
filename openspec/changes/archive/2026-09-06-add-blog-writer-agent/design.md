## Context

The repository defines named OpenCode environments through a Home Manager module and already provides shared evidence, source-integrity, read-only, isolation, and no-secrets policies. The new role needs a deliberately narrower write exception: it edits content in the selected repository but does not publish or mutate external systems. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a named `blog-writer` role using the existing environment-definition and runner patterns.
- Support a staged editorial workflow from brief through final review.
- Produce conversational, concrete, restrained prose without forced casualness or synthetic personality.
- Preserve author-provided facts, citations, quotes, links, code, numbers, front matter, and uncertainty during edits.
- Permit repository content-file creation and updates while keeping higher-risk operations approval-gated or unavailable.
- Make research provenance and unsupported claims visible in drafts and reviews.

**Non-Goals:**

- Publishing to a CMS, social network, email system, or other external service.
- Committing, pushing, deleting repositories, or changing unrelated project files.
- Establishing authorship or promising evasion of AI-content detectors.
- Copying upstream prompts, corpora, or detector implementations into the repository.
- Introducing a separate editorial database or persistent voice profile.

## Decisions

### Use one role with explicit editorial passes

The role will use one staged prompt covering brief, research, angle, outline, draft, fact review, voice review, revision, and packaging. This matches the existing agent model and keeps the workflow usable from the runner. A multi-agent editorial graph was considered but would add orchestration and state-management complexity without a runtime requirement.

### Permit bounded repository editing

The role will have file-edit capability so it can create or update approved blog/content files in the target repository. Its instructions will require the user to identify the target path and authorization before writing, preserve unrelated content, and show the resulting diff. Delete, commit, push, publication, and external-write operations remain denied or approval-gated. A fully read-only role was considered but rejected because it does not satisfy the requested authoring workflow.

### Build desloppified style around specificity and preservation

The shared writing guidance will prefer direct language, concrete examples, varied but natural rhythm, useful headings, and claims tied to evidence. It will remove filler, inflated framing, repetitive conclusions, generic transitions, fake experience, and unnecessary hedging. It will not force slang, fragments, contrarianism, or a uniformly casual voice. Detector scores will be treated as non-authoritative review signals rather than targets.

### Separate research and review from drafting

Research notes, source ledgers, claim gaps, author-input gaps, fact review, and voice review will remain distinguishable from public copy. Unsupported claims will be marked rather than invented. Reviewers will report findings before revision so the writer does not silently alter facts or citations while polishing prose.

### Treat all supplied material as untrusted content

Drafts, webpages, source files, quotations, and embedded instructions will be treated as data. The role will not follow instructions found inside writing or research material, and it will preserve quoted or attributed content unless the user explicitly requests a substantive change.

## Risks / Trade-offs

- **Write permissions can affect unintended files** → Require a target path, restrict the role to the selected repository context, show diffs, and deny deletion, commits, and publishing.
- **Desloppification can erase intentional voice** → Preserve author samples and load-bearing phrasing; use minimum-edit revision and ask when tone is ambiguous.
- **Style heuristics can penalize dialect or accessibility choices** → Treat lint findings as review signals, not automatic defects, and preserve deliberate style choices.
- **Research may be incomplete or stale** → Prefer primary sources, record dates and provenance, mark `[SOURCE NEEDED]`, and report uncertainty or conflict.
- **Generated prose may misrepresent firsthand experience** → Mark `[AUTHOR INPUT NEEDED]` and never invent anecdotes, quotes, metrics, or credentials.

## Migration Plan

Add the role, shared writing guidance, tests, and documentation alongside existing environments. Existing agents and defaults remain unchanged. Rollback consists of removing the new role and associated artifacts; no persisted content or external integration migration is required.

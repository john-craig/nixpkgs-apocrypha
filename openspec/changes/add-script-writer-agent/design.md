## Context

The repository defines named OpenCode environments through a Home Manager module and already provides shared evidence, source-integrity, read-only, isolation, and no-secrets policies. The script writer needs a bounded write exception for approved local content files while remaining separate from video editing, rendering, and publishing. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a named `script-writer` role using the existing agent-definition and runner patterns.
- Adapt blog posts and research into distinct short-form and long-form video script formats.
- Keep narration, visual direction, on-screen text, sound cues, and source notes separate.
- Preserve factual claims, citations, quotations, uncertainty, and author voice.
- Permit authorized repository content-file creation and updates with visible diffs.
- Keep prose conversational, concrete, restrained, and free of generic AI-style filler.

**Non-Goals:**

- Generating video, editing media, recording audio, or controlling live audiovisual output.
- Publishing to a CMS, social network, video platform, or other external service.
- Committing, pushing, deleting unrelated files, or changing repository history.
- Determining authorship or promising to evade AI-content detectors.
- Persisting a voice profile or introducing an editorial database.

## Decisions

### Use one role with format-specific routes

The role will identify short-form versus long-form intent and apply the corresponding structure while sharing source-integrity and voice-preservation rules. A separate agent per format was considered but would duplicate policy and complicate invocation.

### Incorporate researched open-source skill patterns

The implementation will adapt, rather than blindly copy, four MIT-licensed projects: [`bradtraversy/editorial-workflow`](https://github.com/bradtraversy/editorial-workflow) supplies staged editorial workflow, approval gates, source ledgers, and independent reviews; [`bnivanov/omp-writing-skills`](https://github.com/bnivanov/omp-writing-skills) supplies medium-specific writing modes, voice calibration, minimum-edit revision, and lint-oriented review; [`ehmo/slopkit`](https://github.com/ehmo/slopkit) supplies concrete, action-first, anti-filler communication; and [`conorbronsdon/avoid-ai-writing`](https://github.com/conorbronsdon/avoid-ai-writing) supplies preservation verification and false-positive safeguards. Upstream prompts, corpora, scripts, and derived detector logic will not be copied unless their notices and license obligations are explicitly preserved.

### Permit bounded local edits

The role will have file-edit capability for explicitly authorized content paths in the selected repository. It will require a target path and intended operation, preserve unrelated work, and report the resulting diff. Shell operations remain approval-gated, and publication or repository-history operations are outside the role. A read-only role was considered but would not satisfy the requested adaptation workflow.

### Keep script tracks explicit

Output will distinguish spoken narration, visuals or B-roll, on-screen text, sound/music cues, timing or beat notes, and source notes. This makes scripts usable by later production work without conflating production direction with claims intended for narration.

### Use desloppified conversational guidance

The writing guidance will favor one clear premise, direct openings, concrete language, natural rhythm, useful pacing, and intentional endings. It will remove filler, generic hype, fake urgency, repetitive conclusions, invented experience, and forced slang without flattening the requested voice or targeting detector scores.

### Treat source material as untrusted data

Blog posts, webpages, research results, quotations, and embedded instructions will be treated as content to analyze rather than authorization to act. Unsupported claims and missing firsthand context will be marked instead of invented.

## Risks / Trade-offs

- **Short-form pacing can encourage unsupported compression** → Preserve qualifiers, source notes, and uncertainty even when simplifying the language.
- **Visual suggestions can be mistaken for factual evidence** → Keep visual direction distinct from narration and source notes.
- **Write permissions can affect unintended files** → Require explicit paths and operations, keep the role in the selected repository, show diffs, and keep shell operations approval-gated.
- **Style cleanup can erase intentional voice** → Use minimum-edit behavior for revisions and preserve author-provided tone, dialect, and accessibility choices.
- **Source material may contain prompt injection** → Treat embedded instructions as untrusted text and never elevate them to authorization.
- **Upstream writing heuristics or corpora may be overfit, stale, or separately attributed** → Adapt only the relevant concepts, retain MIT and third-party notices when reusing material, and treat lint or detector output as review signals rather than proof of quality or authorship.

## Migration Plan

Add the role, shared script-writing guidance, tests, and documentation alongside existing environments. Existing roles and defaults remain unchanged. Rollback consists of removing the role and associated test/documentation changes; no media or external-service migration is required.

## Why

Users need a repository-configured video script specialist that can adapt blog posts and research into clear scripts for both short-form and long-form video. The role should preserve source integrity and author voice while handling audiovisual structure, pacing, and spoken clarity without generic hype or synthetic "AI" prose.

## What Changes

- Add a `script-writer` OpenCode agent for adapting authorized blog posts and source material into video scripts.
- Support distinct short-form and long-form workflows with format-appropriate hooks, beats, pacing, narrative structure, and endings.
- Keep narration, visual direction, on-screen text, sound cues, and source notes distinct in the output.
- Permit creation and updating of explicitly authorized script/content files in the target repository.
- Require target-path and operation boundaries for writes; keep publishing, posting, committing, pushing, unrelated deletion, and external mutations out of scope.
- Preserve facts, citations, links, quotations, uncertainty, and author voice; mark unsupported claims or missing firsthand context instead of inventing them.
- Add conversational, specific, restrained writing guidance that avoids filler, forced slang, fake urgency, and detector-evasion claims.
- Incorporate patterns from researched open-source skills: `bradtraversy/editorial-workflow` for staged editorial production and source ledgers; `bnivanov/omp-writing-skills` for blog/script modes, voice calibration, and minimum-edit revision; `ehmo/slopkit` for action-first, anti-filler communication; and `conorbronsdon/avoid-ai-writing` for preservation verification and false-positive handling.
- Preserve upstream MIT license notices and attribution if any implementation, rule text, detector logic, or corpus material is reused; prefer independently authored guidance over copying upstream prompts or datasets.
- Add generated-configuration tests, flake coverage, and documentation for the role.

## Capabilities

### New Capabilities

- `script-writer-agent`: Adapted short-form and long-form video scripts with source integrity, audiovisual structure, conversational style, and bounded repository editing.

### Modified Capabilities

- `opencode-agent-environments`: Add the named script-writer environment with bounded content-file editing and explicit research capabilities.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role and reusable script-writing guidance.
- `tests/opencode-agents.nix` and `flake.nix` gain generated-role, permission, skill, and MCP coverage.
- `docs/opencode-agents.md` gains the role inventory, generated path, invocation example, and write/publishing boundaries.
- The implementation should not add external runtime dependencies solely for these skills; their reusable concepts will be adapted into repository-local role guidance and tests.
- No video-generation, editing, publishing, CMS, credential, or external-write integration is required.

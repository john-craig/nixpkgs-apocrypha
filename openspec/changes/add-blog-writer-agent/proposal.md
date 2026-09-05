## Why

Users need a repository-configured writing specialist that can turn research and project context into clear blog drafts without generic, inflated, or synthetic prose. Existing agents provide research and implementation support, but no role owns editorial structure, source-backed claims, voice preservation, or conversational "desloppified" writing.

## What Changes

- Add a `blog-writer` OpenCode agent for research-backed blog drafting, editing, review, and packaging.
- Permit the agent to create and update approved blog/content files in the target repository.
- Require explicit path and authorization boundaries for file writes; keep publishing, posting, committing, and external mutations out of scope.
- Add a staged editorial workflow covering brief, research, outline, draft, fact review, voice review, revision, and final packaging.
- Add conversational, specific, restrained writing guidance that removes AI-style filler without forcing slang, fake personal experience, or detector evasion.
- Preserve facts, links, quotes, code, numbers, front matter, uncertainty, and author voice during revisions.
- Add generated-configuration tests and documentation for the role and its write boundary.

## Capabilities

### New Capabilities

- `blog-writer-agent`: Research-backed blog writing, editorial review, desloppified conversational style, content-file editing, and publication boundary.

### Modified Capabilities

- `opencode-agent-environments`: Add the named blog-writer environment with bounded write permissions, isolated role content, and explicit research capabilities.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role definition and reusable writing/editorial skills or rules.
- `tests/opencode-agents.nix` and `flake.nix` gain generated-role and write-boundary coverage.
- `docs/opencode-agents.md` gains the role inventory, invocation example, workflow, and authorization requirements.
- No publishing service, CMS credential, external write integration, or new runtime dependency is required.

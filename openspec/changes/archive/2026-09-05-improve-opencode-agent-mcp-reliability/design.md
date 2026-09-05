## Context

See `proposal.md` for the motivation. The agent module currently derives
`${server}_* = "allow"` for every declared MCP server, while also allowing a
role to declare a general MCP action such as `ask`. MCP discovery defaults to
five seconds, although several servers are launched through `npx`, `uvx`, or a
remote endpoint. The Home Manager and flake runners both consume the same
generated environment model and must remain behaviorally equivalent.

## Goals / Non-Goals

**Goals:**

- Make MCP permission generation deterministic and consistent with the role's
  configured approval policy.
- Preserve explicitly allowed MCP tools when a role has restrictive wildcard
  permissions.
- Give MCP server classes reliable, auditable discovery timeout settings.
- Cover every MCP-bearing agent in generated-configuration tests.
- Keep Home Manager and direct flake execution aligned.

**Non-Goals:**

- Replacing MCP server packages, endpoints, launchers, or authentication
  mechanisms.
- Broadening any agent's non-MCP permissions.
- Making approval-gated MCP operations autonomous.
- Adding runtime health checks that require live external services during the
  Nix evaluation or ordinary configuration test.

## Decisions

### Derive server permissions from the declared MCP policy

The generator will treat the role's `permission.mcp` action as the default for
each generated `${server}_*` rule, with an explicit per-server override only
where the agent definition requires one. When no MCP action is declared, the
existing safe default will be retained. This avoids unconditional allows and
keeps approval-gated integrations approval-gated.

An alternative was to leave the unconditional server allow and rely on
OpenCode matcher precedence. That was rejected because the verified wildcard
deny behavior suppresses MCP tools despite specific grants, and precedence
would make security behavior difficult to audit.

### Preserve restrictive wildcard behavior without suppressing declared tools

Agents that intentionally allow MCP tools will receive a compatible generated
permission policy rather than a broad deny that makes their declared servers
unusable. Agents that require approval or denial will retain those actions.
The implementation will not solve this by granting unrelated shell, edit, or
network permissions.

### Use explicit timeout classes

The shared MCP timeout remains configurable, while agent definitions receive
explicit values for servers likely to install packages, connect remotely, or
start external bridges. The timeout values and rationale will be visible in
the agent declarations and tested in generated JSON. A discovery timeout is
not treated as proof that the underlying integration is healthy.

### Test generated contracts rather than live services

Tests will inspect generated Home Manager and flake environment JSON for every
MCP-bearing agent, including server names, commands or URLs, permissions, and
timeouts. Existing fake-runner tests will verify that direct execution uses
the generated configuration. Live MCP calls remain targeted smoke tests rather
than mandatory Nix checks.

## Risks / Trade-offs

- [Risk] Changing permission precedence could expose a previously hidden MCP
  tool → Mitigation: assert every affected agent's intended permission action
  and retain explicit denials for shell, task delegation, and high-risk tools.
- [Risk] Longer discovery timeouts delay failures → Mitigation: apply them only
  to known slow-starting server classes and keep failure output observable.
- [Risk] A server may still be unavailable after successful discovery →
  Mitigation: tests validate configuration only, while prompts and runtime
  behavior must report unavailable integrations rather than fabricate results.
- [Risk] Home Manager and flake outputs could diverge → Mitigation: exercise
  both generated paths through the existing module and runner checks.

## Migration Plan

1. Update the shared permission generation and affected MCP declarations.
2. Regenerate and inspect all MCP-bearing environment JSON files.
3. Run focused Nix checks, OpenSpec validation, and configuration diff checks.
4. Run targeted interactive smoke tests for representative allowed,
   approval-gated, local package-based, and remote MCP agents.
5. Roll back by reverting the generator and timeout declaration changes if an
   agent's intended approval behavior regresses.

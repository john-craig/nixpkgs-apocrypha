## 1. Permission Generation

- [x] 1.1 Update the shared agent configuration generator to derive each MCP server tool permission from the role's declared MCP policy, and verify generated rules no longer unconditionally allow approval-gated servers.
- [x] 1.2 Preserve explicitly allowed MCP tools when roles use restrictive wildcard permissions, and verify the research-source-collector generated configuration still exposes its OpenSearch and website-fetch tools while keeping Bash denied.
- [x] 1.3 Audit MCP-bearing agent declarations for explicit approval or denial intent, and verify no server relies on an ambiguous combination of wildcard and server-specific rules.

## 2. Discovery Reliability

- [x] 2.1 Classify the configured MCP servers by local package startup, remote connection, and credential-backed launcher behavior, and document the chosen timeout policy in the declarations or shared defaults.
- [x] 2.2 Add explicit discovery timeouts for MCP servers that may exceed five seconds, and verify the generated JSON contains the intended timeout for every MCP-bearing agent.
- [x] 2.3 Verify timeout failure remains observable and does not cause an unavailable MCP server to be presented as operational.

## 3. Regression Coverage

- [x] 3.1 Extend `tests/opencode-agents.nix` to assert MCP server names, commands or URLs, permissions, and timeouts for all MCP-bearing generated environments, and verify the Nix check passes.
- [x] 3.2 Add coverage for approval-gated MCP behavior, explicitly allowed MCP behavior, and restrictive wildcard behavior, and verify each generated policy matches its agent declaration.
- [x] 3.3 Verify Home Manager and direct flake runner outputs preserve the same MCP declarations and permissions by running the focused agent checks and runner tests.

## 4. Validation

- [x] 4.1 Run the exact representative interactive MCP smoke tests for an explicitly allowed research agent, an approval-gated agent, and a remote MCP agent, and record whether discovery and tool calls behave as configured.
- [x] 4.2 Run `nix build .#checks.x86_64-linux.opencode-agents .#checks.x86_64-linux.opencode-agent --no-link`, `openspec validate improve-opencode-agent-mcp-reliability --type change --strict`, and `git diff --check` successfully.

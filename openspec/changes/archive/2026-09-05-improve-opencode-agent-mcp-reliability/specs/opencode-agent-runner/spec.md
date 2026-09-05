## MODIFIED Requirements

### Requirement: Runner preserves agent permissions

The command SHALL use the selected generated environment without silently
enabling additional tools, suppressing declared MCP tools, or bypassing that
agent's configured permissions. MCP server permissions and discovery settings
SHALL be preserved exactly as generated for the selected environment. Any
OpenCode approval or denial behavior SHALL remain observable to the user.

#### Scenario: Restricted architect invocation
- **WHEN** the runner launches `software-architect` against a project
- **THEN** the session SHALL retain the architect's non-mutating permissions

#### Scenario: MCP permissions are preserved
- **WHEN** the runner launches an agent that declares MCP servers
- **THEN** the session SHALL expose the declared MCP tools with the generated
  allow, approval, or denial behavior and SHALL not replace that behavior with
  a runner-wide default

#### Scenario: MCP discovery fails
- **WHEN** a declared MCP server cannot complete discovery within its generated
  timeout
- **THEN** the runner SHALL expose a clear non-operational or discovery-failure
  result without claiming that the server's tools are available

### Requirement: Direct execution preserves configured permissions

The flake-provided environments SHALL preserve each agent's configured model,
prompt, tool permissions, MCP declarations, MCP discovery timeouts, and
non-mutating or approval-gated boundaries. The flake package SHALL not embed
credentials, secret values, or machine-specific runtime paths.

#### Scenario: Restricted architect invocation from the flake
- **WHEN** the flake runner launches `software-architect` against a project
- **THEN** the session SHALL retain the architect's non-mutating permissions and
  generated prompt

#### Scenario: MCP-backed invocation from the flake
- **WHEN** the flake runner launches an agent with a declared MCP server
- **THEN** the session SHALL retain that server's generated tool availability,
  approval policy, and discovery timeout without requiring Home Manager
  activation

#### Scenario: Package inspection contains no secrets
- **WHEN** the flake package and generated environment files are inspected
- **THEN** they SHALL contain no credential values, authentication tokens, or
  secret file contents

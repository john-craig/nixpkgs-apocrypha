## MODIFIED Requirements

### Requirement: MCP capabilities are explicit

An environment SHALL expose only its declared MCP servers, including their
transport, command or URL, arguments, authentication reference when configured,
and discovery timeout. MCP credentials SHALL NOT be embedded in generated
files. Generated MCP tool permissions SHALL reflect the environment's declared
approval policy: an MCP server declared as approval-gated SHALL not receive an
unconditional tool-level allow, and an MCP server declared as allowed SHALL not
be suppressed by a broader wildcard denial.

#### Scenario: Environment has MCP servers
- **WHEN** an environment declares MCP servers
- **THEN** OpenCode configuration SHALL include those server definitions, their
  usable tool permissions, and their configured discovery timeouts while
  preserving disabled or unavailable integrations as non-operational
  configuration rather than claiming they are available

#### Scenario: Environment has no MCP servers
- **WHEN** an environment declares no MCP servers
- **THEN** its generated configuration SHALL not inherit unrelated MCP servers
  from another environment

#### Scenario: MCP server is approval-gated
- **WHEN** an environment declares an MCP server as approval-gated
- **THEN** generated tool permissions SHALL require the configured approval
  behavior for that server's tools and SHALL not introduce a more permissive
  server-specific rule

#### Scenario: MCP server is explicitly allowed
- **WHEN** an environment declares an MCP server as allowed
- **THEN** its generated tool permissions SHALL make the declared tools
  callable without being blocked by an unrelated broader wildcard denial

#### Scenario: MCP discovery is slow to start
- **WHEN** an MCP server requires more than the default startup interval for
  package installation, process startup, network connection, or tool discovery
- **THEN** the generated configuration SHALL provide a timeout sufficient for
  the declared server class and SHALL report discovery failure clearly if that
  timeout is exceeded

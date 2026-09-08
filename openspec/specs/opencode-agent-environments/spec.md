# opencode-agent-environments Specification

## Purpose

Provides reproducible, named OpenCode agent environments that preserve role-specific behavior while making prompts, tools, policies, and model settings independently configurable through Home Manager.

## Requirements

### Requirement: Dedicated public Home Manager module

The repository SHALL provide a Home Manager module at `homeModules.opencode-agents`, implemented under `home-modules/opencode-agents`, and SHALL apply its configuration only when its own enable option is enabled.

#### Scenario: Agent module is imported but disabled
- **WHEN** a Home Manager configuration imports `homeModules.opencode-agents` with agent configuration disabled
- **THEN** it SHALL not materialize agent files or alter the existing global OpenCode customization files

#### Scenario: Agent module is composed with customization module
- **WHEN** a Home Manager configuration imports both `homeModules.opencode-agents` and `homeModules.opencode`
- **THEN** both modules SHALL generate their respective files without requiring Panoply or overwriting each other's configuration responsibilities

### Requirement: Named environment configuration

The system SHALL expose named OpenCode environments with stable names and descriptions,
SHALL support selecting one environment as the default, and SHALL define the developer
environment with autonomous edit and command execution permissions by default. Existing
explicit permission configuration SHALL remain able to narrow or widen those defaults.
The system SHALL provide a stable `script-writer` environment with repository content-file
editing enabled while publication, commit, push, deletion, and external mutation behavior
remains unavailable or approval-gated by default.

#### Scenario: Environment is selected
- **WHEN** a configured user selects a named environment
- **THEN** OpenCode SHALL load that environment's prompt, model settings, skills, rules, subagents, MCP servers, and applicable policy metadata

#### Scenario: Developer works autonomously
- **WHEN** a user selects the developer environment without overriding its permissions
- **THEN** the developer SHALL be allowed to read project files, edit files, and execute commands without per-operation approval

#### Scenario: Developer permissions are restricted
- **WHEN** a user supplies an explicit permission override for the developer environment
- **THEN** the generated configuration SHALL honor the override and restrict the affected operations accordingly

#### Scenario: Godot game developer environment is selected
- **WHEN** a configured user selects the `godot-game-developer` environment
- **THEN** the generated environment SHALL contain only its declared Godot skills and MCP servers, preserve project and credential boundaries, and keep high-risk runtime operations approval-gated or unavailable

#### Scenario: Podcast writer environment is selected
- **WHEN** a configured user selects `podcast-writer`
- **THEN** the generated environment SHALL load only its podcast-writing guidance, approved corpus/output boundaries, and explicitly declared capabilities, with browsing and unrelated file access denied or unavailable by default

#### Scenario: Research source collector environment is selected
- **WHEN** a configured user selects `research-source-collector`
- **THEN** the generated environment SHALL load only its source-collection guidance and approved public research capabilities, with transcript generation, private-file access, and external writes denied or unavailable by default

#### Scenario: Script writer edits authorized content
- **WHEN** a configured user selects the `script-writer` environment and authorizes a target content path
- **THEN** the generated environment SHALL permit the role to create or update that repository content while preserving its configured restrictions on deletion, publication, commits, pushes, and external writes

#### Scenario: Unknown environment is selected
- **WHEN** a user selects a name that is not configured
- **THEN** configuration evaluation or environment resolution SHALL fail clearly rather than silently falling back to another role

### Requirement: Role content is materialized

Each configured environment SHALL materialize its instructions, skills, rules, and subagent profiles in OpenCode-compatible locations or configuration fields, preserving their names and instruction text.

#### Scenario: Role content is generated
- **WHEN** Home Manager evaluates an enabled environment
- **THEN** generated configuration SHALL contain the environment instructions and all selected named skills, rules, and subagents without requiring Panoply at runtime

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
- **THEN** its generated configuration SHALL not inherit unrelated MCP servers from another environment

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

### Requirement: Authorization and isolation boundaries are preserved

The migrated environments SHALL preserve each source environment's authentication mode and project-discovery intent, and SHALL fail closed when a required credential reference is missing.

#### Scenario: Shared authentication is configured
- **WHEN** an environment uses shared authentication
- **THEN** generated configuration SHALL reference the shared authentication mechanism without copying secret contents

#### Scenario: Required authentication reference is missing
- **WHEN** an environment requires a file or API-key reference and none is supplied
- **THEN** evaluation SHALL fail with an environment-specific error

### Requirement: Environment content is isolated

The system SHALL prevent one named environment's instructions, tools, or role profiles from being implicitly merged into another environment, except for explicitly declared shared definitions.

#### Scenario: Two environments are configured
- **WHEN** two environments declare different MCP servers or role content
- **THEN** each generated environment SHALL contain only its own declarations and explicitly shared content

### Requirement: Migration coverage is auditable

The repository SHALL document the mapping of all 15 source environments and identify any Codex behavior that has no direct OpenCode equivalent.

#### Scenario: Migration coverage is reviewed
- **WHEN** the documented migration inventory is compared with the source environments
- **THEN** every source environment SHALL be accounted for as migrated, intentionally omitted with a reason, or blocked by an explicit unresolved incompatibility

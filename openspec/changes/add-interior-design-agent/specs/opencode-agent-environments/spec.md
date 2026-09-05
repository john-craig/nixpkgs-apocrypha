## MODIFIED Requirements

### Requirement: Named environment configuration

The system SHALL expose named OpenCode environments with stable names and descriptions,
SHALL support selecting one environment as the default, and SHALL define the developer
environment with autonomous edit and command execution permissions by default. Existing
explicit permission configuration SHALL remain able to narrow or widen those defaults.
The system SHALL provide a stable `interior-design-assistant` environment with isolated
interior-design guidance and an explicit `librecad` MCP declaration whose CAD mutation,
save, export, and external-write operations are approval-gated or unavailable by default.

#### Scenario: Environment is selected
- **WHEN** a configured user selects a named environment
- **THEN** OpenCode SHALL load that environment's prompt, model settings, skills, rules, subagents, MCP servers, and applicable policy metadata

#### Scenario: Developer works autonomously
- **WHEN** a user selects the developer environment without overriding its permissions
- **THEN** the developer SHALL be allowed to read project files, edit files, and execute commands without per-operation approval

#### Scenario: Developer permissions are restricted
- **WHEN** a user supplies an explicit permission override for the developer environment
- **THEN** the generated configuration SHALL honor the override and restrict the affected operations accordingly

#### Scenario: Interior design environment is selected
- **WHEN** a configured user selects the `interior-design-assistant` environment
- **THEN** the generated environment SHALL contain only its declared interior-design content and `librecad` MCP, preserve source and credential boundaries, and not inherit unrelated MCP servers

#### Scenario: Unknown environment is selected
- **WHEN** a user selects a name that is not configured
- **THEN** configuration evaluation or environment resolution SHALL fail clearly rather than silently falling back to another role

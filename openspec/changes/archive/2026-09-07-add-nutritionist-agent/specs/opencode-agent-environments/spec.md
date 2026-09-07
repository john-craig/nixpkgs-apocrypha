## MODIFIED Requirements

### Requirement: Named environment configuration

The system SHALL expose named OpenCode environments with stable names and descriptions, SHALL support selecting one environment as the default, and SHALL define the developer environment with autonomous edit and command execution permissions by default. Existing explicit permission configuration SHALL remain able to narrow or widen those defaults. The system SHALL provide a stable `nutritionist` environment whose default permissions are read-only and whose role content is isolated from unrelated environments.

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

#### Scenario: Nutritionist environment is selected
- **WHEN** a configured user selects the `nutritionist` environment without overriding its permissions
- **THEN** the generated environment SHALL allow read and research operations while denying mutation, secret access, and external writes by default

#### Scenario: Unknown environment is selected
- **WHEN** a user selects a name that is not configured
- **THEN** configuration evaluation or environment resolution SHALL fail clearly rather than silently falling back to another role

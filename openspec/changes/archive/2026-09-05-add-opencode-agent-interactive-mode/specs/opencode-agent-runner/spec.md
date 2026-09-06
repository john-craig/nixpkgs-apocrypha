## MODIFIED Requirements

### Requirement: Run an agent against a directory

The system SHALL provide an executable command that accepts an agent name and an existing
directory, then either invokes OpenCode in non-interactive run mode with a non-empty prompt
or starts OpenCode's interactive terminal interface. The command SHALL be available both
from the Home Manager-installed runner and from the flake's `opencode-agent` package without
requiring prior activation of the Home Manager module.

#### Scenario: Valid implementation invocation
- **WHEN** the command receives a configured agent, an existing directory, and a non-empty prompt without interactive mode
- **THEN** it SHALL run OpenCode in non-interactive mode with the selected agent, target directory, and exact prompt

#### Scenario: Valid interactive flake invocation
- **WHEN** a user runs the flake-provided `opencode-agent` executable with a configured agent, an existing directory, and the interactive option
- **THEN** it SHALL start OpenCode's interactive terminal interface with the selected agent and target directory without requiring a prompt

#### Scenario: Valid direct flake invocation
- **WHEN** a user runs the flake-provided `opencode-agent` executable with a configured agent, an existing directory, and a non-empty prompt
- **THEN** it SHALL resolve the flake-provided generated environment and run OpenCode without requiring the Home Manager module to have been deployed

### Requirement: Invalid runner inputs fail safely

The command SHALL reject missing or unknown agents and missing or non-directory targets with a
non-zero exit status and a clear error without starting an OpenCode session. Non-interactive
mode SHALL reject a missing prompt, while interactive mode SHALL not require one. The command
SHALL reject an invocation that requests both interactive mode and a prompt. Direct flake
execution SHALL also reject an unavailable or invalid environment root without silently
falling back to an unintended configuration.

#### Scenario: Unknown agent
- **WHEN** the command receives an agent name that has no generated environment
- **THEN** it SHALL report the unknown agent and exit without invoking OpenCode

#### Scenario: Invalid directory
- **WHEN** the command receives a path that does not exist or is not a directory
- **THEN** it SHALL report the invalid target and exit without invoking OpenCode

#### Scenario: Missing non-interactive prompt
- **WHEN** the command does not receive a prompt and interactive mode was not requested
- **THEN** it SHALL report the missing prompt and exit without invoking OpenCode

#### Scenario: Conflicting interactive prompt
- **WHEN** the command receives both the interactive option and a prompt
- **THEN** it SHALL report the conflicting options and exit without invoking OpenCode

#### Scenario: Missing direct execution environment
- **WHEN** direct flake execution cannot locate its generated agent environments
- **THEN** it SHALL report the missing environment and exit without invoking OpenCode

## ADDED Requirements

### Requirement: Interactive mode preserves configured environments

Interactive mode SHALL select the same generated configuration for the requested agent as
non-interactive mode and SHALL preserve the agent's model, prompt, permissions, MCP declarations,
and approval behavior. Interactive mode SHALL not enable automatic approval or otherwise bypass
configured safety boundaries.

#### Scenario: Interactive architect session retains restrictions
- **WHEN** interactive mode launches `software-architect` against a project
- **THEN** the OpenCode session SHALL use the generated architect configuration and retain its non-mutating permissions

#### Scenario: Interactive mode uses an explicit environment root
- **WHEN** interactive mode receives an environment-root override pointing to a valid generated environment set
- **THEN** it SHALL use that environment set for agent resolution and OpenCode configuration

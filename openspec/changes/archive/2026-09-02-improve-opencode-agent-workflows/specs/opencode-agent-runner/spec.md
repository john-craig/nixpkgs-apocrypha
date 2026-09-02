## Purpose

Provides one predictable command for launching a configured OpenCode agent with a
specific target directory and prompt, reducing manual environment-selection steps.

## ADDED Requirements

### Requirement: Run an agent against a directory

The system SHALL provide an executable command that accepts an agent name, an existing
directory, and a prompt, then invokes OpenCode in non-interactive run mode using that
directory as its project context.

#### Scenario: Valid implementation invocation
- **WHEN** the command receives a configured agent, an existing directory, and a non-empty prompt
- **THEN** it SHALL run OpenCode with the selected agent, target directory, and exact prompt

### Requirement: Invalid runner inputs fail safely

The command SHALL reject missing or unknown agents, missing or non-directory targets,
and missing prompts with a non-zero exit status and a clear error without starting an
OpenCode session.

#### Scenario: Unknown agent
- **WHEN** the command receives an agent name that has no generated environment
- **THEN** it SHALL report the unknown agent and exit without invoking OpenCode

#### Scenario: Invalid directory
- **WHEN** the command receives a path that does not exist or is not a directory
- **THEN** it SHALL report the invalid target and exit without invoking OpenCode

### Requirement: Runner preserves agent permissions

The command SHALL use the selected generated environment without silently enabling
additional tools or bypassing that agent's configured permissions. Any OpenCode approval
or denial behavior SHALL remain observable to the user.

#### Scenario: Restricted architect invocation
- **WHEN** the runner launches `software-architect` against a project
- **THEN** the session SHALL retain the architect's non-mutating permissions

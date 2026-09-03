## MODIFIED Requirements

### Requirement: Run an agent against a directory

The system SHALL provide an executable command that accepts an agent name, an existing
directory, and a prompt, then invokes OpenCode in non-interactive run mode using that
directory as its project context. The command SHALL be available both from the
Home Manager-installed runner and from the flake's `opencode-agent` package without
requiring prior activation of the Home Manager module.

#### Scenario: Valid implementation invocation
- **WHEN** the command receives a configured agent, an existing directory, and a non-empty prompt
- **THEN** it SHALL run OpenCode with the selected agent, target directory, and exact prompt

#### Scenario: Valid direct flake invocation
- **WHEN** a user runs the flake-provided `opencode-agent` executable with a configured agent, an existing directory, and a non-empty prompt
- **THEN** it SHALL resolve the flake-provided generated environment and run OpenCode without requiring the Home Manager module to have been deployed

### Requirement: Invalid runner inputs fail safely

The command SHALL reject missing or unknown agents, missing or non-directory targets,
and missing prompts with a non-zero exit status and a clear error without starting an
OpenCode session. Direct flake execution SHALL also reject an unavailable or invalid
environment root without silently falling back to an unintended configuration.

#### Scenario: Unknown agent
- **WHEN** the command receives an agent name that has no generated environment
- **THEN** it SHALL report the unknown agent and exit without invoking OpenCode

#### Scenario: Invalid directory
- **WHEN** the command receives a path that does not exist or is not a directory
- **THEN** it SHALL report the invalid target and exit without invoking OpenCode

#### Scenario: Missing direct execution environment
- **WHEN** direct flake execution cannot locate its generated agent environments
- **THEN** it SHALL report the missing environment and exit without invoking OpenCode

## ADDED Requirements

### Requirement: Direct flake execution exposes generated environments

The flake SHALL expose an `opencode-agent` package and a documented invocation that
includes the repository's generated agent environments as runtime data. The direct
invocation SHALL support an explicit environment-root override for users who need to
run a separately generated or customized environment.

#### Scenario: Flake package is runnable
- **WHEN** a user runs `nix run <flake>#opencode-agent -- --help`
- **THEN** the command SHALL start without Home Manager activation and describe its required agent, directory, prompt, and environment options

#### Scenario: Explicit environment root
- **WHEN** a user supplies an environment-root override pointing to a valid generated environment set
- **THEN** the runner SHALL use that environment set for agent resolution and OpenCode configuration

### Requirement: Direct execution preserves configured permissions

The flake-provided environments SHALL preserve each agent's configured model, prompt,
tool permissions, MCP declarations, and non-mutating or approval-gated boundaries. The
flake package SHALL not embed credentials, secret values, or machine-specific runtime
paths.

#### Scenario: Restricted architect invocation from the flake
- **WHEN** the flake runner launches `software-architect` against a project
- **THEN** the session SHALL retain the architect's non-mutating permissions and generated prompt

#### Scenario: Package inspection contains no secrets
- **WHEN** the flake package and generated environment files are inspected
- **THEN** they SHALL contain no credential values, authentication tokens, or secret file contents

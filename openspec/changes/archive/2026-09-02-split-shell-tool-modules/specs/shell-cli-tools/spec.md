## MODIFIED Requirements

### Requirement: CLI application modules

The repository SHALL provide independently enableable Home Manager modules for Alucard, ChatGPT CLI, Claude Code, Dismas, Instagram CLI, Paru, Tea, Toot, and Twitch CLI, with each implementation located in its own directory under `home-modules` and without requiring Panoply's `userServices` options. The existing aggregate `shell-cli-tools` module SHALL remain available as a composition entry point during migration.

#### Scenario: CLI modules are disabled
- **WHEN** a consumer imports the CLI modules without enabling a feature
- **THEN** the feature SHALL add no package, generated file, activation action, shell alias, or ambient session variable

#### Scenario: CLI module is enabled
- **WHEN** a consumer enables one CLI feature
- **THEN** the corresponding per-tool module SHALL install its documented package and configure only that feature's files or activation behavior

### Requirement: Portable Alucard deployment helpers

The Alucard module SHALL provide its host configuration file, deployment/build helper functions, completion initialization, and logging/error filtering without requiring a Panoply repository environment variable; repository and deployment paths SHALL be explicit configuration values.

#### Scenario: Alucard is enabled
- **WHEN** a consumer enables Alucard with a repository path
- **THEN** its package, host configuration, completion setup, and deployment helpers SHALL use that configured path and preserve command exit status

### Requirement: Secret-backed CLI files

ChatGPT, Toot, Twitch, and other credential-backed features SHALL read credentials from configurable external paths or supported secret integrations and SHALL write generated files with restrictive permissions without embedding secret contents in Nix source.

#### Scenario: Credential-backed feature is enabled
- **WHEN** a consumer enables a feature requiring credentials
- **THEN** activation SHALL use the configured external secret paths and SHALL create or update its runtime file with user-only permissions

### Requirement: No shell mutation

The migrated per-tool CLI modules SHALL NOT define shell aliases or ambient session/environment variables.

#### Scenario: CLI packages are installed
- **WHEN** any migrated CLI feature is enabled
- **THEN** commands SHALL be available through managed packages or documented executable paths without modifying `programs.zsh.shellAliases` or `home.sessionVariables`

### Requirement: Verification and documentation

The repository SHALL document each per-tool CLI module's enablement, package, files, credential inputs, compatibility aggregate, and runtime assumptions and SHALL provide focused evaluation coverage for enabled and disabled behavior.

#### Scenario: CLI contract is tested
- **WHEN** the documented checks run
- **THEN** they SHALL verify each per-tool module's public option, package/file outputs, secret-path handling, aggregate composition, and absence of shell mutation without live authenticated services

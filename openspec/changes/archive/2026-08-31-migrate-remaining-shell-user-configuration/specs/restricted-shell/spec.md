## Purpose

Provides a reusable Home Manager module for configuring lshell with declarative command allowlists and a managed restricted-shell entry point.

## ADDED Requirements

### Requirement: Declarative lshell configuration

The repository SHALL expose an independently enableable lshell Home Manager module using the repository's `lshell` package, configurable permitted commands, permitted sudo commands, and a read-only login-shell path.

#### Scenario: Lshell is enabled

- **WHEN** a consumer enables lshell with command lists
- **THEN** the module SHALL install the package and generate `~/.config/lshell/lshell.conf` with the configured allowlists and restrictions

#### Scenario: Lshell is disabled

- **WHEN** the module is imported but disabled
- **THEN** it SHALL not install the restricted shell wrapper or configuration file

### Requirement: Safe configuration generation

The generated lshell configuration SHALL quote command values safely and preserve the configured warning, logging, SSH, and forbidden-character behavior.

#### Scenario: Command contains special characters

- **WHEN** a permitted command value requires quoting
- **THEN** the generated configuration SHALL remain syntactically valid and preserve the literal command value

### Requirement: Verification and documentation

The repository SHALL document the restricted-shell option paths, login-shell integration, allowlist safety model, and SHALL provide focused configuration evaluation coverage.

#### Scenario: Lshell contract is tested

- **WHEN** the documented checks run
- **THEN** they SHALL verify package/export behavior, generated configuration, disabled behavior, and safe quoting without changing system users

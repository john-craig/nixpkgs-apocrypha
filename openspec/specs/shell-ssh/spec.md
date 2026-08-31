# shell-ssh Specification

## Purpose
Provides a portable Home Manager SSH module that preserves evak's agent setup and host match blocks while making Panoply cluster topology an explicit input.

## Requirements

### Requirement: Declarative SSH module

The repository SHALL provide an independently enableable SSH module that configures the SSH agent, OpenSSH client, identity files, match blocks, and active connection options without requiring Panoply's cluster modules.

#### Scenario: SSH module is enabled

- **WHEN** a consumer enables the SSH module with host definitions
- **THEN** Home Manager SHALL generate the corresponding SSH configuration and enable the user SSH agent

### Requirement: Explicit host topology

The SSH module SHALL accept typed or validated host/address definitions for dynamic cluster hosts and SHALL fail clearly when a referenced host has no usable address; static hosts SHALL remain representable without cluster data.

#### Scenario: Dynamic host has an address

- **WHEN** an enabled match block references a supplied host with a usable address
- **THEN** the generated SSH configuration SHALL use the selected address and preserve its user, port, identity, and options

#### Scenario: Dynamic host is unresolved

- **WHEN** an enabled match block references a host with no usable address
- **THEN** evaluation SHALL fail with an actionable host-resolution error

### Requirement: SSH helper dependencies

The module SHALL configure required TOTP/honeypot helper packages and proxy commands only when those specialized entries are enabled, and SHALL not embed private key or secret values.

#### Scenario: Specialized SSH entry is enabled

- **WHEN** a consumer enables the TOTP/honeypot entry
- **THEN** the required helper package and proxy command SHALL be present while secret material remains external or explicitly supplied

### Requirement: Verification and documentation

The repository SHALL document host-definition inputs, identity-file assumptions, agent behavior, specialized helper requirements, and SHALL provide static and dynamic host evaluation tests.

#### Scenario: SSH contract is tested

- **WHEN** the documented checks run
- **THEN** they SHALL verify generated match blocks, unresolved-host errors, helper gating, and public exports without contacting remote hosts

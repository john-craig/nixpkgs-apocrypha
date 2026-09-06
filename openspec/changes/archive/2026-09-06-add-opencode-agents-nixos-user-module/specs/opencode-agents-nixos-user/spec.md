## Purpose

Provides a reusable NixOS module that creates a configurable system user and
gives that user a Home Manager profile with OpenCode and the repository's
declarative OpenCode agent environments enabled.

## ADDED Requirements

### Requirement: Configurable OpenCode user

The module SHALL expose an enable switch and a required username, and SHALL
allow the consumer to provide supported NixOS user attributes for that user,
including identity, home-directory, group, shell, description, and normal-user
settings.

#### Scenario: Consumer enables a configured user

- **WHEN** the consumer enables the module and supplies a username plus user details
- **THEN** the evaluated NixOS configuration SHALL contain a system user with that username and the requested supported attributes

#### Scenario: Module is disabled

- **WHEN** the module is disabled
- **THEN** it SHALL not create or modify the configured OpenCode system user or Home Manager entry

#### Scenario: Username is missing or invalid

- **WHEN** the module is enabled without a valid username
- **THEN** evaluation SHALL fail with a clear module option or assertion error

### Requirement: OpenCode Home Manager composition

An enabled module SHALL configure the selected user's Home Manager profile with
the repository's `opencode` and `opencode-agents` home modules and SHALL enable
both corresponding module options.

#### Scenario: User profile is evaluated

- **WHEN** an enabled module is evaluated with Home Manager available
- **THEN** the user's Home Manager configuration SHALL include both OpenCode home modules and SHALL set `evak.opencode.enable` and `evak.opencode-agents.enable` to true

#### Scenario: Home Manager is unavailable

- **WHEN** the module is enabled without the Home Manager NixOS module providing the required per-user configuration interface
- **THEN** evaluation SHALL fail with an actionable error identifying the missing Home Manager integration

### Requirement: User Home Manager customization

The module SHALL provide a supported Home Manager customization attrset for the
selected user, including OpenCode and agent settings, while preserving the
required module imports and enabled OpenCode options.

#### Scenario: Consumer customizes agent settings

- **WHEN** the consumer supplies Home Manager configuration for the selected user
- **THEN** that configuration SHALL be merged into the user's profile and SHALL affect the generated OpenCode or agent configuration

#### Scenario: Customization attempts to disable required modules

- **WHEN** consumer customization sets either required enable option to false
- **THEN** the module SHALL retain both required enable options as true

### Requirement: User isolation and stable targeting

The module SHALL apply the generated Home Manager configuration only to the
configured username and SHALL not alter unrelated system users or Home Manager
profiles.

#### Scenario: Existing unrelated users are present

- **WHEN** the system contains other users or Home Manager profiles
- **THEN** enabling the module SHALL leave their user attributes and Home Manager configuration unchanged

#### Scenario: User identity changes

- **WHEN** the consumer changes the configured username
- **THEN** the system user and Home Manager profile targeted by the module SHALL change to the new username rather than continuing to configure the previous user

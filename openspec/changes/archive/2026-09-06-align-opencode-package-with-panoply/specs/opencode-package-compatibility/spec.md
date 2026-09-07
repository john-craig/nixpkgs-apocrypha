## Purpose

Defines the OpenCode package version consumed by this repository's Home Manager
modules so users can adopt them without an unintended runtime-version change
from the supported Panoply OpenCode environment.

## ADDED Requirements

### Requirement: Supported OpenCode package version

The repository SHALL provide `pkgs.opencode` at the Panoply compatibility target
version `1.18.21` for supported systems, and the default
`evak.opencode-agents.opencodePackage` value SHALL resolve to that package.

#### Scenario: Default package is evaluated

- **WHEN** a consumer evaluates the repository package set with the supported system and default overlay
- **THEN** `pkgs.opencode.version` SHALL equal `1.18.21`

#### Scenario: Agent runner uses the default package

- **WHEN** `evak.opencode-agents` is enabled without an explicit `opencodePackage`
- **THEN** its runner SHALL be configured to invoke the aligned default OpenCode package

#### Scenario: Package version drifts

- **WHEN** the resolved default OpenCode package version is not `1.18.21`
- **THEN** the repository's package or evaluation checks SHALL fail rather than silently accepting the drift

### Requirement: Explicit package override

The Home Manager agent module SHALL continue to allow a consumer to provide an
explicit `evak.opencode-agents.opencodePackage` for an independent package set,
and SHALL use that package for the generated runner instead of the default
package.

#### Scenario: Consumer supplies an aligned package

- **WHEN** a consumer provides an explicit OpenCode package at version `1.18.21`
- **THEN** the generated agent runner SHALL use that package

#### Scenario: Consumer supplies a different package intentionally

- **WHEN** a consumer provides an explicit package with a different version
- **THEN** the module SHALL use the explicit package and SHALL not replace it with the repository default

### Requirement: NixOS user module package wiring

The OpenCode-enabled NixOS user module SHALL document and test how a consumer
with an independent nixpkgs package set supplies the aligned OpenCode package to
the selected Home Manager profile.

#### Scenario: Consumer package set lacks the aligned default

- **WHEN** a consumer enables the NixOS user module with a package set that does not provide the aligned default
- **THEN** the consumer SHALL be able to set `homeManager.evak.opencode-agents.opencodePackage` to an explicit `1.18.21` package and obtain a working runner

#### Scenario: Package is unavailable

- **WHEN** OpenCode is neither available as the default package nor supplied through the explicit override
- **THEN** evaluation SHALL fail with the existing actionable `opencode-agents` package assertion

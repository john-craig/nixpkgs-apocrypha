## Purpose

Provides reusable Home Manager configuration for Git, GitHub CLI, direnv, and portable user-facing Nix development tooling.

## ADDED Requirements

### Requirement: Git and GitHub CLI configuration

The repository SHALL provide independently enableable Git and GitHub CLI modules that preserve the active package, Git identity/signing settings, default branch, SSH agent-related behavior, and secret-backed GitHub hosts configuration without requiring Panoply modules.

#### Scenario: Development tools are enabled

- **WHEN** a consumer enables Git or GitHub CLI
- **THEN** the corresponding package and declarative configuration SHALL be installed with external credential material kept out of Nix source

### Requirement: Direnv integration

The direnv module SHALL provide enablement, zsh integration, and configurable nix-direnv support through standard Home Manager options.

#### Scenario: Direnv is enabled

- **WHEN** a consumer enables direnv with nix-direnv enabled
- **THEN** direnv SHALL be installed with zsh integration and nix-direnv configured

### Requirement: Portable Nix client settings

The repository SHALL distinguish user-portable Nix client settings from NixOS-only daemon, cross-compilation, QEMU, and system configuration, and SHALL NOT require unsupported NixOS options from a Home Manager module.

#### Scenario: Nix user module is enabled

- **WHEN** a consumer enables the portable Nix module
- **THEN** supported client settings and packages SHALL be configured, while system-only settings SHALL be documented as a separate host concern

### Requirement: No shell mutation

The development-tool modules SHALL NOT define shell aliases or ambient session/environment variables.

#### Scenario: Development tools are configured

- **WHEN** Git, GitHub CLI, direnv, or Nix tooling is enabled
- **THEN** the modules SHALL configure programs and files without modifying shell aliases or session variables

### Requirement: Verification and documentation

The repository SHALL document option paths, package dependencies, signing/credential assumptions, direnv behavior, and the NixOS split, and SHALL provide focused evaluation coverage.

#### Scenario: Development contract is tested

- **WHEN** the documented checks run
- **THEN** they SHALL verify exports, settings, package outputs, secret-path handling, and the absence of unsupported system options

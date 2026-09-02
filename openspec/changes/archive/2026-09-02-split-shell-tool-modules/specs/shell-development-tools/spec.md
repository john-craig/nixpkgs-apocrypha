## MODIFIED Requirements

### Requirement: Git and GitHub CLI configuration

The repository SHALL provide independently enableable Git and GitHub CLI modules, each in its own directory under `home-modules`, that preserve the active package, Git identity/signing settings, default branch, SSH agent-related behavior, and secret-backed GitHub hosts configuration without requiring Panoply modules. The existing aggregate `shell-development-tools` module SHALL remain available as a composition entry point during migration.

#### Scenario: Development tools are enabled
- **WHEN** a consumer enables Git or GitHub CLI
- **THEN** the corresponding per-tool module SHALL install its package and declarative configuration with external credential material kept out of Nix source

### Requirement: Direnv integration

The direnv module SHALL be independently enableable and located in its own `home-modules` directory, providing zsh integration and configurable nix-direnv support through standard Home Manager options.

#### Scenario: Direnv is enabled
- **WHEN** a consumer enables direnv with nix-direnv enabled
- **THEN** direnv SHALL be installed with zsh integration and nix-direnv configured

### Requirement: Portable Nix client settings

The Nix client module SHALL be independently enableable and located in its own `home-modules` directory. It SHALL distinguish user-portable Nix client settings from NixOS-only daemon, cross-compilation, QEMU, and system configuration, and SHALL NOT require unsupported NixOS options from a Home Manager module.

#### Scenario: Nix user module is enabled
- **WHEN** a consumer enables the portable Nix module
- **THEN** supported client settings and packages SHALL be configured, while system-only settings SHALL be documented as a separate host concern

### Requirement: No shell mutation

The per-tool development modules SHALL NOT define shell aliases or ambient session/environment variables.

#### Scenario: Development tools are configured
- **WHEN** Git, GitHub CLI, direnv, or Nix tooling is enabled
- **THEN** the modules SHALL configure programs and files without modifying shell aliases or session variables

### Requirement: Verification and documentation

The repository SHALL document each per-tool module's option paths, package dependencies, signing/credential assumptions, direnv behavior, NixOS split, and compatibility aggregate, and SHALL provide focused evaluation coverage.

#### Scenario: Development contract is tested
- **WHEN** the documented checks run
- **THEN** they SHALL verify exports, settings, package outputs, secret-path handling, aggregate composition, and the absence of unsupported system options

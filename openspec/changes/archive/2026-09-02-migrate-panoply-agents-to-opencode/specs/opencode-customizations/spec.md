## MODIFIED Requirements

### Requirement: Public and explicit module

The repository SHALL expose a Home Manager module at `homeModules.opencode`, and the module SHALL apply its configuration only when `evak.opencode.enable` is enabled. The module SHALL provide the existing global OpenCode customizations independently of the dedicated `homeModules.opencode-agents` module and without requiring Panoply modules.

#### Scenario: Module is imported but disabled

- **WHEN** a Home Manager configuration imports `homeModules.opencode` with `evak.opencode.enable` false
- **THEN** the module SHALL not install OpenCode customization files or configure OpenCode plugins

#### Scenario: Module is enabled

- **WHEN** a Home Manager configuration imports `homeModules.opencode` with `evak.opencode.enable` true
- **THEN** the module SHALL generate the documented OpenCode TUI customization files without requiring Panoply modules

### Requirement: Documentation and verification

The repository SHALL document module import, enablement, generated paths, plugin behavior, notification configuration, audio/runtime assumptions, and troubleshooting commands, and SHALL provide focused generated-configuration evaluation coverage for this module.

#### Scenario: Configuration contract is tested

- **WHEN** the documented Nix checks are run
- **THEN** they SHALL verify exports, disabled behavior, theme selection, plugin versions, notifier threshold/sound/command settings, and fallback configuration without requiring live OpenCode or desktop services

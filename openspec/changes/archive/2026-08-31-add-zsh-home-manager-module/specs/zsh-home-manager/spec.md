## Purpose

Provides a portable Home Manager module for evak's reusable zsh workflow without importing personal aliases or environment variables.

## ADDED Requirements

### Requirement: Public Home Manager module

The repository SHALL expose a Home Manager module at `homeModules.zsh` in both the NUR attribute set and flake outputs, and the module SHALL evaluate without Panoply-specific options.

#### Scenario: Consumer imports the module

- **WHEN** a Home Manager configuration imports `homeModules.zsh`
- **THEN** the module SHALL evaluate without requiring Panoply modules or `userServices` options

### Requirement: Explicit zsh activation

The module SHALL apply its zsh configuration only when `programs.zsh.enable` is enabled and SHALL NOT define shell aliases or session environment variables.

#### Scenario: Zsh is disabled

- **WHEN** the module is imported with `programs.zsh.enable` false
- **THEN** it SHALL NOT install zsh plugins, zsh startup files, aliases, or session environment variables

#### Scenario: Zsh is enabled

- **WHEN** the module is imported with `programs.zsh.enable` true
- **THEN** it SHALL apply the core evak zsh configuration

### Requirement: Core interactive zsh behavior

When enabled, the module SHALL enable completion, autosuggestions, syntax highlighting, and history substring search, configure completion initialization and the pinned Alpine keybindings plugin, and install the `.zprofile` that sources `/etc/environment` when present and then `.zshrc`.

#### Scenario: Enabled profile contains core behavior

- **WHEN** a Home Manager evaluation enables zsh with the module imported
- **THEN** the resolved configuration SHALL enable completion, autosuggestions, syntax highlighting, and history substring search, contain the core plugin declarations and completion initialization, contain no shell aliases or session variables, and include `.zprofile` content

### Requirement: Optional zsh features

The module SHALL provide explicit opt-in controls for evak's long-running-command notifications and extended history metadata; disabled features SHALL not alter the corresponding Home Manager options.

#### Scenario: Optional features are disabled

- **WHEN** zsh is enabled but the notification and history features are not enabled
- **THEN** the module SHALL omit the notification plugin and extended history settings

### Requirement: Configurable non-fatal notifications

When command notifications are enabled, the module SHALL support configurable threshold, Gotify endpoint, token path, and fallback command values; notification failure SHALL NOT change the status of the completed shell command.

#### Scenario: Long command completes

- **WHEN** a command runs longer than the configured threshold and notification support is enabled
- **THEN** the notifier SHALL attempt the configured notification path and fallback without blocking or failing the shell session

#### Scenario: Notification configuration is unavailable

- **WHEN** the token, endpoint, or fallback command is unavailable
- **THEN** the shell SHALL remain usable and the completed command's status SHALL be preserved

### Requirement: Documentation and verification

The repository SHALL document module import, standard activation, notification and history options, and the desktop assumptions, and SHALL provide focused evaluation coverage.

#### Scenario: Repository checks the module contract

- **WHEN** the documented Nix checks are run
- **THEN** they SHALL verify public export, disabled behavior, core behavior, and optional features without requiring a live interactive shell or desktop session

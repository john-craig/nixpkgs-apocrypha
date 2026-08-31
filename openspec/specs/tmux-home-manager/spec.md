# tmux-home-manager Specification

## Purpose
Provides a reusable Home Manager module for evak's tmux workflow, including its clipboard integration, plugin, and keyboard behavior, so the configuration can be consumed outside Panoply.

## Requirements

### Requirement: Public Home Manager module

The repository SHALL expose a Home Manager module at `homeModules.tmux` in both the NUR attribute set and flake outputs.

#### Scenario: Consumer imports the module

- **WHEN** a Home Manager configuration imports the repository's `homeModules.tmux` module
- **THEN** the module SHALL evaluate without requiring Panoply-specific options or modules

### Requirement: Explicit tmux activation

The module SHALL apply its tmux configuration only when the standard Home Manager option `programs.tmux.enable` is enabled.

#### Scenario: Tmux is disabled

- **WHEN** the module is imported and `programs.tmux.enable` is false
- **THEN** the module SHALL NOT add its tmux plugin, extra configuration, or clipboard package

#### Scenario: Tmux is enabled

- **WHEN** the module is imported and `programs.tmux.enable` is true
- **THEN** the module SHALL apply the evak tmux configuration and required clipboard dependency

### Requirement: Evak tmux behavior

When enabled, the module SHALL configure Emacs key mode, the yank plugin, the blue status-bar theme customization, the documented hotkeys for entering and controlling copy mode, the copy-mode navigation and shift-selection bindings, and `C-c` copy through `wl-copy`.

#### Scenario: Enabled profile contains theme and mode hotkeys

- **WHEN** a Home Manager evaluation enables `programs.tmux` with the module imported
- **THEN** the resolved configuration SHALL contain `tmuxPlugins.yank`, Emacs key mode, `status-style bg=blue`, an unbound/rebound `C-Space` copy-mode entry hotkey, the copy-mode navigation and shift-selection bindings, and a `wl-copy` copy command

### Requirement: Documentation and verification

The repository SHALL document how to import and enable the module and SHALL provide focused evaluation coverage for its public export and enabled behavior.

#### Scenario: Repository checks the module contract

- **WHEN** the repository's documented validation commands are run
- **THEN** they SHALL evaluate the module export and verify the enabled configuration without requiring a running graphical session

# opencode-customizations Specification

## Purpose
Provides a reusable Home Manager module for evak's documented OpenCode TUI theme, completion feedback, and productivity plugins without coupling it to Panoply's broader agent launcher.

## Requirements

### Requirement: Public and explicit module

The repository SHALL expose a Home Manager module at `homeModules.opencode`, and the module SHALL apply its configuration only when `evak.opencode.enable` is enabled.

#### Scenario: Module is imported but disabled

- **WHEN** a Home Manager configuration imports `homeModules.opencode` with `evak.opencode.enable` false
- **THEN** the module SHALL not install OpenCode customization files or configure OpenCode plugins

#### Scenario: Module is enabled

- **WHEN** a Home Manager configuration imports `homeModules.opencode` with `evak.opencode.enable` true
- **THEN** the module SHALL generate the documented OpenCode TUI customization files without requiring Panoply modules

### Requirement: Declarative SynthWave TUI theme

When enabled, the module SHALL install `~/.config/opencode/tui.json` and a valid global theme under `~/.config/opencode/themes/`, select that theme by default, and provide semantic colors derived from the VSCodium SynthWave '84 palette.

#### Scenario: OpenCode starts with the managed theme

- **WHEN** OpenCode starts after Home Manager activation
- **THEN** its TUI configuration SHALL select the managed SynthWave theme without interactive setup

#### Scenario: Theme files are generated

- **WHEN** the Home Manager configuration is evaluated
- **THEN** the generated TUI and theme JSON SHALL contain the expected schema declarations and primary/accent/background semantic roles

### Requirement: Completion notifier

When enabled, the module SHALL configure `@mohak34/opencode-notifier@0.1.36` for completion sound and notification feedback only for sessions lasting longer than 10 seconds, while allowing notification behavior while the terminal is focused.

#### Scenario: Long OpenCode session completes

- **WHEN** an OpenCode session completes after more than 10 seconds
- **THEN** the notifier SHALL play the managed `ding.mp3` completion sound and attempt completion notification

#### Scenario: Short OpenCode session completes

- **WHEN** an OpenCode session completes in 10 seconds or less
- **THEN** the notifier SHALL not produce qualifying completion feedback

### Requirement: Gotify and Hyprland fallback

The notifier command SHALL use configurable Gotify endpoint, token path, and priority values, attempt Gotify delivery first, and attempt a local Hyprland notification when Gotify is unavailable or fails; notification failures SHALL NOT affect OpenCode.

#### Scenario: Gotify delivery succeeds

- **WHEN** a qualifying completion occurs and the configured token is readable and Gotify responds successfully
- **THEN** the command SHALL deliver the completion event to Gotify without requiring the Hyprland fallback

#### Scenario: Gotify delivery fails

- **WHEN** a qualifying completion occurs and Gotify is unavailable or its token cannot be read
- **THEN** the command SHALL attempt the configured Hyprland fallback and return without failing the OpenCode session

### Requirement: Productivity plugins

When enabled, the module SHALL configure `opencode-codex-quota@1.0.1` and `opencode-quotes-plugin/tui` alongside the pinned completion notifier.

#### Scenario: Productivity plugins load

- **WHEN** OpenCode loads the managed plugin configuration
- **THEN** `/codex_quota` SHALL be available and the quotes plugin SHALL provide rotating home-screen tips and its quote-management commands

### Requirement: Documentation and verification

The repository SHALL document module import, enablement, generated paths, plugin behavior, notification configuration, audio/runtime assumptions, and troubleshooting commands, and SHALL provide focused generated-configuration evaluation coverage.

#### Scenario: Configuration contract is tested

- **WHEN** the documented Nix checks are run
- **THEN** they SHALL verify exports, disabled behavior, theme selection, plugin versions, notifier threshold/sound/command settings, and fallback configuration without requiring live OpenCode or desktop services

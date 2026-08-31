## Purpose

Provides a reusable Home Manager module that declaratively installs and configures evak's VSCodium editor, including its SynthWave '84 visual customization and terminal workflow.

## ADDED Requirements

### Requirement: Public Home Manager module

The repository SHALL expose a Home Manager module at `homeModules.vscodium` in both the NUR attribute set and flake outputs, and the module SHALL evaluate without Panoply-specific options.

#### Scenario: Consumer imports the module

- **WHEN** a Home Manager configuration imports `homeModules.vscodium`
- **THEN** the module SHALL evaluate without requiring Panoply modules or `userServices` options

### Requirement: Explicit VSCodium activation

The module SHALL apply its VSCodium configuration only when `programs.vscode.enable` is enabled.

#### Scenario: VSCodium is disabled

- **WHEN** the module is imported with `programs.vscode.enable` false
- **THEN** it SHALL NOT configure the VSCodium package, profile, extensions, or settings

#### Scenario: VSCodium is enabled

- **WHEN** the module is imported with `programs.vscode.enable` true
- **THEN** it SHALL select and configure the VSCodium package and default profile

### Requirement: SynthWave visual customization

When enabled, the module SHALL install the SynthWave '84 marketplace extension, select the `SynthWave '84` color theme, and apply the SynthWave neon CSS patch to the VSCodium workbench.

#### Scenario: Enabled profile uses the theme

- **WHEN** a Home Manager evaluation enables VSCodium with the module imported
- **THEN** the resolved profile SHALL select `SynthWave '84` and include the SynthWave extension, and the selected package SHALL contain the generated neon CSS patch

### Requirement: Editor workflow configuration

When enabled, the module SHALL configure JetBrains Mono with ligatures, open untrusted workspace files, disable terminal chords, use tmux through `zsh -c tmux` as the default Linux terminal profile, and install the documented extension and keybinding set.

#### Scenario: Enabled profile contains editor workflow

- **WHEN** a Home Manager evaluation enables VSCodium with the module imported
- **THEN** the default profile SHALL contain the documented settings, Jinja/Python/GitHub Copilot/Nix IDE/SynthWave extensions, and the three custom Ctrl+Shift keybindings

### Requirement: Declarative extension management

The module SHALL manage extensions through the default declarative profile and SHALL NOT enable `mutableExtensionsDir` together with that profile.

#### Scenario: Profile and extension mode are compatible

- **WHEN** the module is evaluated
- **THEN** the resolved configuration SHALL use the default profile for extensions and SHALL leave mutable extension management disabled or unset

### Requirement: Documentation and verification

The repository SHALL document importing and enabling the module, its declarative extension behavior, tmux/zsh runtime assumptions, and SHALL provide focused evaluation coverage.

#### Scenario: Repository checks the module contract

- **WHEN** the documented Nix checks are run
- **THEN** they SHALL verify public export, disabled behavior, theme configuration, profile settings, extensions, keybindings, and option compatibility without requiring a graphical session

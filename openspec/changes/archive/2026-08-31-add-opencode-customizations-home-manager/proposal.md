## Why

Panoply now has a documented OpenCode TUI customization spec, but those customizations remain coupled to its private primary-agent module. Moving the TUI theme, completion feedback, and productivity plugins into this repository will make the configuration reusable as a standalone Home Manager module while keeping launcher, model, MCP, and shell-alias concerns separate.

## What Changes

- Add a standalone `homeModules.opencode` Home Manager module for OpenCode TUI customizations.
- Generate the global `~/.config/opencode/tui.json` and managed SynthWave-style theme file.
- Configure the pinned notifier plugin with a 10-second completion threshold, focused-terminal sound behavior, and the existing `ding.mp3` completion sound.
- Generate a Gotify-first notification command with a Hyprland fallback, using configurable endpoint, token path, and priority values.
- Configure `opencode-codex-quota@1.0.1` and `opencode-quotes-plugin/tui` alongside `@mohak34/opencode-notifier@0.1.36`.
- Make the module's enablement, theme, notification, and plugin settings explicit and independent of Panoply's `userServices` hierarchy.
- Export the module from both the NUR attribute set and the flake's `homeModules` output.
- Add focused generated-JSON evaluation coverage and detailed user documentation based on Panoply's existing TUI documentation.

## Capabilities

### New Capabilities

- `opencode-customizations`: Declarative OpenCode TUI theme, completion feedback, and productivity plugin configuration.

### Modified Capabilities

## Impact

- New OpenCode Home Manager module, generated configuration files, notification command, theme, and completion sound asset under `home-modules/`.
- `default.nix` and `flake.nix` Home Manager exports.
- OpenCode files under `~/.config/opencode/`, including `tui.json`, theme, notifier configuration, and plugin settings.
- OpenCode's runtime plugin downloads and Linux desktop/audio notification dependencies.
- README documentation and focused Nix/JQ-style configuration tests.

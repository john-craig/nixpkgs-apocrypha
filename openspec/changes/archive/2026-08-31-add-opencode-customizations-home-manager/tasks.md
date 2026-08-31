## 1. Module and Generated Configuration

- [x] 1.1 Create the standalone `home-modules/opencode` module with typed `evak.opencode` options and verify it evaluates without Panoply-specific options
- [x] 1.2 Add the managed `ding.mp3` asset and generate `tui.json` plus the SynthWave theme; verify theme selection, schema fields, and semantic color roles
- [x] 1.3 Generate notifier configuration with the pinned notifier, 10-second threshold, focused-terminal behavior, managed sound path, and command hook; verify each generated JSON value
- [x] 1.4 Generate the Gotify-first/Hyprland-fallback command with configurable endpoint, token path, and priority; verify no token contents are stored and failures are suppressed
- [x] 1.5 Add quota and quotes plugin identifiers and gate all generated files on `evak.opencode.enable`; verify disabled evaluation produces no customization files

## 2. Public API and Verification

- [x] 2.1 Export `opencode` from `default.nix` and the flake `homeModules` output; verify `nix eval path:$PWD#homeModules.opencode` resolves successfully
- [x] 2.2 Add focused Nix/JQ-style evaluation coverage for exports, disabled behavior, generated theme, plugin identifiers, notifier settings, sound path, command arguments, and fallback values; verify it passes against pinned nixpkgs
- [x] 2.3 Document module import, enablement, generated paths, plugin commands, notification setup, audio/runtime assumptions, troubleshooting, and separation from the primary-agent launcher; verify documented paths and option names match the module
- [x] 2.4 Run `nix flake check path:$PWD` and OpenSpec validation, then verify no unrelated outputs regress

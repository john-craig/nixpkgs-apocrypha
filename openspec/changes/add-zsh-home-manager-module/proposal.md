## Why

The zsh setup for user `evak` is currently distributed across Panoply's private user-module tree and profile files. Publishing the reusable zsh behavior as a Home Manager module will make the shell environment reproducible from this NUR repository without importing personal aliases or environment variables.

## What Changes

- Add a reusable `homeModules.zsh` module based on Panoply's zsh configuration.
- Enable zsh completion, autosuggestions, syntax highlighting, and history substring search while preserving the pinned Alpine keybindings plugin and `.zprofile` behavior.
- Provide opt-in long-running-command notifications and extended history metadata matching the current evak setup.
- Make notification endpoint, token path, threshold, and fallback command configurable instead of embedding Panoply host/user paths in the reusable module.
- Exclude personal aliases, session variables, PATH changes, and derived directory variables from the reusable module.
- Export the module from both the NUR attribute set and the flake's `homeModules` output.
- Add focused evaluation coverage and usage documentation.

## Capabilities

### New Capabilities

- `zsh-home-manager`: Reusable and opt-in personal zsh configuration for Home Manager users.

### Modified Capabilities

## Impact

- New zsh module and supporting shell/plugin files under `home-modules/`.
- `default.nix` and `flake.nix` Home Manager exports.
- Home Manager's `programs.zsh` and `home.file` configuration.
- The pinned `alpine-zsh-config` source and runtime notification dependencies such as `curl`, `date`, and an optional Hyprland fallback.
- Documentation and focused Nix evaluation tests.

## Why

The tmux setup currently lives inside the Panoply user module tree, so it cannot be reused by Home Manager configurations that consume this NUR repository. Extracting the evak tmux behavior into a published Home Manager module provides one declarative, portable source for the plugin, clipboard dependency, and keybindings.

## What Changes

- Add a reusable `homeModules.tmux` Home Manager module containing the tmux configuration currently defined in Panoply for user `evak`.
- Activate the configuration through Home Manager's standard `programs.tmux.enable` option rather than requiring Panoply's `userServices` option namespace.
- Preserve the `tmuxPlugins.yank` plugin, Emacs key mode, blue status-bar theme customization, copy-mode entry hotkey, copy-mode navigation, shift-selection bindings, and `wl-copy` integration.
- Ensure `wl-clipboard` is available to the configured copy binding.
- Export the module from both the NUR attribute set and the flake's `homeModules` output.
- Add focused evaluation coverage and usage documentation for importing and enabling the module.

## Capabilities

### New Capabilities

- `tmux-home-manager`: Reusable Home Manager tmux configuration matching the evak Panoply setup.

### Modified Capabilities

## Impact

- New module files under `home-modules/` and a module export in `default.nix` and `flake.nix`.
- Home Manager's existing `programs.tmux` options and generated tmux configuration.
- The `tmuxPlugins.yank` and `wl-clipboard` package dependencies supplied by the consuming nixpkgs/Home Manager evaluation.
- Repository README or module documentation describing the public import and enablement contract.

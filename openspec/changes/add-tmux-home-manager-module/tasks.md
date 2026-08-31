## 1. Module Implementation

- [x] 1.1 Create the standalone `home-modules/tmux` Home Manager module and verify it evaluates without Panoply-specific `userServices` options
- [x] 1.2 Port the source tmux plugin, package dependency, Emacs key mode, blue status-bar theme customization, `C-Space` copy-mode entry hotkey, copy-mode navigation, shift-selection, and `wl-copy` bindings; verify the enabled module exposes each expected setting
- [x] 1.3 Gate the module behavior on `programs.tmux.enable` and verify a disabled evaluation adds no tmux-specific package, plugin, or extra configuration

## 2. Public Exports

- [x] 2.1 Export `tmux` from `default.nix` as `homeModules.tmux` and verify the NUR attribute set exposes the module
- [x] 2.2 Enable the flake `homeModules` output and verify `nix flake show` lists the tmux module

## 3. Verification and Documentation

- [x] 3.1 Add a focused Home Manager/Nix evaluation test for importability, enabled behavior, disabled behavior, and required dependencies; verify it passes with the repository's pinned nixpkgs
- [x] 3.2 Document the consumer import and `programs.tmux.enable` example, source provenance, theme customization, mode-entry hotkeys, and Wayland clipboard assumption; verify documented paths and option names match the implementation
- [x] 3.3 Run `nix flake check` and the focused module evaluation, then verify no unrelated repository outputs regress

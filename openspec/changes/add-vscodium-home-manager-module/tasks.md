## 1. Module and Package

- [x] 1.1 Create the standalone `home-modules/vscodium` module and verify it evaluates without Panoply-specific options
- [x] 1.2 Build the SynthWave '84 marketplace extension and patched VSCodium package; verify the fixed marketplace metadata and CSS patch are wired into the selected package
- [x] 1.3 Port the default profile settings, tmux terminal profile, extensions, and Ctrl+Shift keybindings; verify each expected value appears in an enabled evaluation
- [x] 1.4 Use the declarative profile without `mutableExtensionsDir` and verify the incompatible option combination is absent
- [x] 1.5 Gate all module behavior on `programs.vscode.enable` and verify disabled evaluation adds no package, profile, extensions, or settings

## 2. Public API and Verification

- [x] 2.1 Export `vscodium` from `default.nix` and the flake `homeModules` output; verify `nix eval path:$PWD#homeModules.vscodium` resolves successfully
- [x] 2.2 Add focused Nix evaluation coverage for importability, disabled behavior, patched package/profile selection, theme, settings, extensions, keybindings, and option compatibility; verify it passes against pinned nixpkgs
- [x] 2.3 Document import, activation, declarative extension management, and tmux/zsh assumptions; verify paths and option names match the module
- [x] 2.4 Run `nix flake check path:$PWD` and OpenSpec validation, then verify no unrelated outputs regress

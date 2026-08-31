## 1. Core Module

- [x] 1.1 Create the standalone `home-modules/zsh` module and verify it evaluates without Panoply-specific options
- [x] 1.2 Port core zsh activation, completion, autosuggestions, syntax highlighting, history substring search, completion initialization, pinned Alpine keybindings plugin, and `.zprofile`; verify each appears in an enabled evaluation without aliases or session variables
- [x] 1.3 Gate core configuration on `programs.zsh.enable` and verify disabled evaluation adds no zsh files, plugins, or configuration

## 2. Personal Features

- [x] 2.1 Add typed opt-in options for notifications and history metadata; verify defaults leave these features disabled
- [x] 2.2 Exclude personal aliases, PATH setup, and directory-derived variables from the reusable module; verify enabled evaluation leaves aliases and session variables empty
- [x] 2.3 Port long-running-command notification behavior with configurable threshold, endpoint, token path, and fallback; verify generated configuration contains no mandatory hard-coded secret path and failures remain non-fatal by inspection/evaluation

## 3. Public API and Verification

- [x] 3.1 Export `zsh` from `default.nix` and the flake `homeModules` output; verify `nix eval path:$PWD#homeModules.zsh` resolves successfully
- [x] 3.2 Add focused Nix evaluation coverage for importability, disabled behavior, core settings, absence of aliases/session variables, history metadata, and notification configuration; verify it passes against pinned nixpkgs
- [x] 3.3 Document import, activation, notification requirements, and filesystem assumptions; verify paths and option names match the module
- [x] 3.4 Run `nix flake check path:$PWD` and OpenSpec validation, then verify no unrelated outputs regress

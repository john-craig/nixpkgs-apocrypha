## 1. Shared Runner Extraction

- [x] 1.1 Extract the implementor shell application construction from the Home Manager module into reusable package logic without duplicating the workflow script.
- [x] 1.2 Preserve the existing CLI, agent selection, provider behavior, worktree lifecycle, package overrides, and cleanup options.
- [x] 1.3 Refactor the Home Manager module to consume the shared runner and verify disabled evaluation and existing option assertions remain unchanged.

## 2. Flake Package

- [x] 2.1 Add the `openspec-implementor` package definition with runtime inputs for Git, jq, OpenSpec, `opencode-agent`, OpenCode, `gh`, and `tea`.
- [x] 2.2 Construct the package with the existing `opencode-nix` overlay and packaged agent environments without embedding Home Manager state or credentials.
- [x] 2.3 Expose the package through `default.nix`, `legacyPackages`, and flake `packages` outputs with correct metadata and main program.
- [x] 2.4 Verify `nix run .#openspec-implementor -- --help` works without Home Manager activation and accepts the existing workflow arguments.

## 3. Compatibility and Security

- [x] 3.1 Verify Home Manager package overrides and workflow options still affect the installed command after runner extraction.
- [x] 3.2 Verify direct execution uses the packaged OpenCode agent environments, permissions, prompts, and fallback behavior.
- [x] 3.3 Inspect package outputs for credentials, secret contents, private keys, and machine-specific paths.
- [x] 3.4 Verify missing runtime authentication produces an actionable provider/OpenCode error without mutating substitute configuration.

## 4. Tests and Documentation

- [x] 4.1 Add direct package checks for help output, invalid arguments, executable presence, and package metadata.
- [x] 4.2 Extend the fake local-remote workflow check to exercise the direct flake package and compare its behavior with the Home Manager runner.
- [x] 4.3 Add checks for GitHub and Gitea provider selection, pending pull-request handling, cleanup, and preserved failure state.
- [x] 4.4 Document local and remote `nix run` commands, runtime authentication, package closure behavior, and the fact that execution publishes changes.
- [x] 4.5 Run `git diff --check`, `openspec validate expose-openspec-implementor-flake-runner --type change --strict`, focused checks, and `nix flake check`.

## 1. Package Alignment

- [x] 1.1 Update the existing OpenCode package input or overlay lock state so `pkgs.opencode.version` evaluates to `1.18.21`; verify the package evaluates on every supported flake system.
- [x] 1.2 Preserve the existing `pkgs.opencode` and `overlays.opencode-nix` package boundaries; verify no second OpenCode derivation or Panoply-specific flake dependency is introduced.
- [x] 1.3 Add a focused flake check asserting the resolved default OpenCode package version is exactly `1.18.21` and that the executable is present; verify the check fails if the version drifts.

## 2. Home Manager And NixOS Wiring

- [x] 2.1 Extend `opencode-agents` evaluation coverage to verify its default `opencodePackage` is the aligned package and its runner invokes that package; verify the existing explicit package override still wins.
- [x] 2.2 Extend the OpenCode-enabled NixOS user module fixture to cover an explicit aligned `homeManager.evak.opencode-agents.opencodePackage` override and missing-package failure; verify required module enables remain forced.
- [x] 2.3 Update package/version documentation and consumer migration guidance; verify the documented target, default package path, and explicit override option match the evaluated configuration.

## 3. Scope And Verification

- [x] 3.1 Confirm the change does not modify MCP inventories, MCP environment mapping, global OpenCode settings, permissions, notifications, launchers, diagnostics, OpenCode server behavior, or OpenChamber integration; verify with the final diff review.
- [x] 3.2 Run the focused package, OpenCode-agent, and NixOS-user checks plus `nix flake check`; verify all relevant checks pass without unrelated worktree changes.

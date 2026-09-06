## 1. Module Interface

- [x] 1.1 Add the new NixOS module file and export it from `nixos-modules/default.nix`; verify the flake exposes the documented module attribute.
- [x] 1.2 Define the enable, required username, supported system-user details, and per-user Home Manager customization options; verify invalid usernames and unsupported option shapes fail during module evaluation.
- [x] 1.3 Add the configured system user under `users.users.${username}` without changing unrelated users; verify the evaluated user attributes match the consumer's input.

## 2. Home Manager Composition

- [x] 2.1 Detect the Home Manager per-user interface and add a targeted assertion for configurations that enable the module without Home Manager; verify the failure message identifies the required import.
- [x] 2.2 Compose the existing `home-modules/opencode` and `home-modules/opencode-agents` modules into `home-manager.users.${username}`; verify both modules and both enable options are present in the evaluated profile.
- [x] 2.3 Merge consumer Home Manager settings while forcing the two required enable options to remain true; verify custom agent definitions and OpenCode settings are preserved and false enable overrides do not disable the modules.
- [x] 2.4 Preserve the existing OpenCode package contract and document the required package/overlay or explicit `opencodePackage` configuration; verify missing package failures remain actionable.

## 3. Verification And Documentation

- [x] 3.1 Add module evaluation tests covering enabled and disabled states, username/user details, unrelated-user isolation, username targeting, customization, and required-enable precedence; verify the relevant Nix test/check succeeds.
- [x] 3.2 Add a Home Manager integration fixture or test configuration that evaluates the generated per-user profile and materializes representative OpenCode and agent files; verify the generated profile contains the runner and expected configuration paths.
- [x] 3.3 Add a consumer-facing documentation example showing Home Manager import, NixOS module import, username/user options, package availability, and Home Manager customization; verify names match the exported module and option interface.
- [x] 3.4 Run formatting, the focused module tests, and `nix flake check`; verify no unrelated worktree files are modified.

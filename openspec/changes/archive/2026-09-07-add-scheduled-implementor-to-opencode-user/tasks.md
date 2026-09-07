## 1. NixOS Module Composition

- [x] 1.1 Add the existing implementor scheduler Home Manager module to the OpenCode NixOS user's composed imports and verify the module evaluates with the existing OpenCode profile.
- [x] 1.2 Preserve forced `evak.opencode.enable` and `evak.opencode-agents.enable` behavior while leaving the scheduler disabled by default; verify customization cannot disable the required OpenCode modules and no scheduler units appear unless enabled.

## 2. Tests And Documentation

- [x] 2.1 Extend the NixOS user-module fixture to verify scheduler imports and forwarding of valid scheduler configuration, including the generated service and timer when enabled; verify unrelated users remain unchanged.
- [x] 2.2 Document the exact `homeManager.evak.project-manager.automated-development-workflows.implementor-scheduler` opt-in configuration and verify it matches the existing scheduler module options.

## 3. Verification

- [x] 3.1 Run the focused NixOS-user and scheduler checks plus `nix flake check`; verify all relevant checks pass and the diff does not change scheduler runtime semantics or unrelated OpenCode behavior.

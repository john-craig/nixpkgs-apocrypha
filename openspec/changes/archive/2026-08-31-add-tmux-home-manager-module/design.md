## Context

The target repository is a small NUR repository that currently exports packages, overlays, and an empty `nixosModules` set. Its `flake.nix` has a commented `homeModules` placeholder, and `default.nix` documents the same NUR namespace but does not expose it. The source behavior is `modules/userModules/shellModules/tmux/default.nix` in Panoply; that module is gated by Panoply-specific `userServices` options and cannot be imported independently.

## Goals / Non-Goals

**Goals:**

- Make the tmux setup consumable as a standalone Home Manager module from this repository.
- Preserve the observable tmux behavior of the source module, including clipboard support and the yank plugin.
- Keep enablement explicit and compatible with normal Home Manager module composition.
- Provide an evaluation-level test that exercises both enabled and disabled behavior.

**Non-Goals:**

- Refactoring Panoply or changing its existing `userServices.shellServices.tmux` interface.
- Adding NixOS-specific user creation, system services, or host configuration.
- Generalizing every tmux setting into new custom options.
- Adding runtime integration tests that require a graphical Wayland session or a live tmux server.

## Decisions

- **Expose a flake/NUR module named `tmux`.** Consumers will import `inputs.nixpkgs-apocrypha.homeModules.tmux` and set `programs.tmux.enable = true`. This follows the repository's existing module namespace conventions and avoids inventing a second enable option. A custom `userServices` option was rejected because it would require Panoply's module hierarchy.
- **Gate all configuration on `programs.tmux.enable`.** Importing the module alone will not install packages or alter tmux configuration. This matches Home Manager expectations and allows consumers to compose the module without side effects.
- **Copy the source module's behavior, not its surrounding implementation.** The public module will configure `programs.tmux.keyMode`, `plugins`, and `extraConfig`, plus `home.packages` for `wl-clipboard`. The `extraConfig` must retain both the source's theme customization (`status-style bg=blue`) and its mode-entry/control hotkeys, including `C-Space` to enter copy mode and `C-c` to copy and cancel. Panoply's `userServices.hybridEnvironment.assertPackages` integration is not portable and will not be reproduced.
- **Keep configuration literal and focused.** The source keybindings and status setting will be retained as tmux `extraConfig` rather than converted into a large new option schema. This minimizes drift and keeps the module easy to compare with the source.
- **Test through a minimal Home Manager module evaluation.** The test will verify the exported module can be imported, the enabled profile contains the expected package/plugin/configuration values, and the disabled profile does not add the setup. A full desktop or tmux-server test is unnecessary for this declarative contract.

## Risks / Trade-offs

- **Home Manager option merging may conflict with consumer tmux settings** -> Use normal module composition and document that consumers can override supported `programs.tmux` values after importing the module.
- **`wl-copy` may be unavailable outside Wayland** -> Keep the source behavior unchanged and document the Wayland clipboard assumption; the module must not add host-specific display configuration.
- **Upstream Home Manager changes may rename plugin/package options** -> Evaluate the module against the flake's pinned nixpkgs and include the relevant option path in the test.
- **The copied source configuration can drift from Panoply** -> Record the source path in module documentation and keep the public module's behavior intentionally limited to the currently requested extraction.

## Migration Plan

1. Add the module and exports, then validate the target flake and focused Home Manager evaluation.
2. In a consuming Home Manager configuration, import `homeModules.tmux` and enable `programs.tmux`.
3. Confirm the generated tmux configuration and copy binding on the target user's machine.
4. Roll back by removing the module import and `programs.tmux.enable` assignment; no state migration is required.

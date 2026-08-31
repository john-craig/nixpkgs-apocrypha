## Context

Panoply's `modules/userModules/shellModules/zsh/default.nix` is gated by `userServices.shellServices.zsh` and configures standard Home Manager zsh options, a checked-in `.zprofile`, and two optional features: command notifications and extended history metadata. The notification plugin currently hard-codes a UID-specific token path, Gotify URL, and Hyprland fallback. Separate evak profile modules add aliases, PATH setup, and directory-derived environment variables, which are intentionally excluded here.

## Goals / Non-Goals

**Goals:**

- Expose one standalone `homeModules.zsh` module that does not depend on Panoply's option hierarchy.
- Preserve the observable reusable interactive zsh behavior without importing personal aliases or environment variables.
- Keep standard zsh activation explicit through `programs.zsh.enable`.
- Make environment-specific notification values configurable and safe to omit.
- Test enabled, disabled, and notification/history behavior through Nix evaluation.

**Non-Goals:**

- Changing Panoply's existing module or user profile.
- Publishing secrets, token contents, or a mandatory host-specific notification endpoint.
- Supporting every shell used by the repository or replacing unrelated shell modules.
- Dynamically discovering arbitrary filesystem trees during Nix evaluation.

## Decisions

- **Use `homeModules.zsh` with standard activation.** Consumers import the module and set `programs.zsh.enable = true`; this follows the tmux module pattern and avoids recreating Panoply's `userServices` hierarchy. A second top-level enable flag is rejected as redundant.
- **Keep core behavior under standard Home Manager options.** Completion, autosuggestions, syntax highlighting, history substring search, plugins, history, init content, and `.zprofile` will use their native Home Manager representations so consumers can compose or override them. The module will not define aliases or session variables.
- **Expose feature switches in a dedicated namespace.** Notification and history metadata will use a module-owned namespace such as `evak.zsh`, with defaults disabled unless explicitly requested. Personal aliases and environment variables are excluded rather than exposed as module features.
- **Generate notification behavior from configuration.** The notifier will receive the threshold, Gotify URL, token path, and fallback command from Nix. Missing or failing notification dependencies will be non-fatal, and token contents will never be stored in the repository.
- **Do not port personal aliases and variables.** The separate Panoply profile fragments remain the owner of those settings, preventing service-specific aliases and filesystem assumptions from entering this reusable module.
- **Retain the pinned Alpine keybindings plugin.** The existing source revision and hash will be preserved, with evaluation checking the plugin declaration. The commented-out shift-select plugin remains out of scope because it is not active behavior.

## Risks / Trade-offs

- **Notification hooks run in interactive zsh** -> Keep handlers short, catch command failures, and ensure notification failures never alter the command's exit status.
- **Home Manager zsh option names or plugin semantics may change** -> Validate against the repository's pinned nixpkgs and inspect generated zsh configuration.

## Migration Plan

1. Add and export the module, then run focused evaluation and flake checks.
2. Import `homeModules.zsh` in the consuming profile and enable `programs.zsh`.
3. Enable notifications explicitly, supplying endpoint/token values appropriate to the host.
4. Compare `.zprofile`, completion, keybindings, history, and long-command feedback with the Panoply profile.
5. Roll back by removing the module import and feature options; no state migration is required.

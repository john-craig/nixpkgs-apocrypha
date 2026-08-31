## Why

Panoply's remaining shell-oriented user configuration is still coupled to its private `userServices.shellServices` hierarchy, while this repository now provides standalone modules for tmux, zsh, VSCodium, and OpenCode customizations. A coordinated migration plan will make the remaining CLI tools and shell-adjacent services reusable without copying Panoply's host topology, secrets, or personal shell aliases into this repository.

## What Changes

- Add standalone Home Manager modules for the remaining shell configuration, grouped into four capability specs.
- Migrate the core CLI tools: Alucard, ChatGPT CLI, Claude Code, Dismas, Instagram CLI, Paru, Tea, Toot, and Twitch CLI.
- Migrate Git, GitHub CLI, direnv/nix-direnv, and the user-facing Nix client configuration, splitting out NixOS-only settings where Home Manager cannot own them.
- Migrate the SSH agent and SSH match-block configuration with explicit cluster/address inputs rather than a dependency on Panoply's cluster module tree.
- Migrate lshell's restricted-shell configuration and permitted-command options, building on this repository's existing `lshell` package.
- Leave Codex and the primary-agent launcher out of this change; the already migrated OpenCode TUI customization remains separate.
- Preserve app-specific files and secret-backed activation behavior where appropriate, but keep tokens external and configurable.
- Do not migrate shell aliases or ambient session/environment variables, including the previously removed evak zsh aliases and variables.
- Export each resulting capability through the repository's `homeModules` namespace, add focused evaluations, and document migration boundaries and dependencies.

## Capabilities

### New Capabilities

- `shell-cli-tools`: Home Manager modules for the remaining standalone shell/CLI applications.
- `shell-development-tools`: Git, GitHub CLI, direnv, and user-facing Nix client configuration.
- `shell-ssh`: Declarative SSH agent and match-block configuration with explicit topology inputs.
- `restricted-shell`: Declarative lshell configuration using the repository's lshell package.

### Modified Capabilities

## Impact

- New Home Manager modules, supporting scripts/configuration assets, tests, and documentation under `home-modules/` and `tests/`.
- `homeModules` exports in `home-modules/default.nix` and the flake/NUR namespace.
- Packages including `alucard`, `chatgpt-cli`, `claude-code`, `dismas`, `gh`, `git`, `instagram-clii`, `nix-prefetch-git`, `paru`, `pre-commit`, `tea`, `toot`, `twitch-cli`, `totp-port-knockd-rs`, and `lshell` where available.
- Home Manager options for `home.packages`, `home.file`, `home.activation`, `home.sessionPath`, `programs.*`, `services.ssh-agent`, and portable assertions.
- Secret integration for GitHub, ChatGPT, Toot, and Twitch must remain external and must not be hard-coded into the repository.

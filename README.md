# nixpkgs-apocrypha

John Craig’s (`evak`) personal [NUR](https://nur.nix-community.org/)
repository for Nix packages, modules, overlays, and configuration helpers.

## Packages

- [`lshell`](./pkgs/lshell) — a limited shell with fine-grained command
  allow-listing.

## Local development

Evaluate the repository’s package set with:

```console
nix flake check
nix build .#lshell
```

Package definitions live under [`pkgs/`](./pkgs), and each package may include
its own README with usage notes and metadata. Exported packages and other NUR
namespaces are assembled in [`default.nix`](./default.nix).

## Home Manager modules

Remaining shell user configuration is provided by the standalone capability
modules documented in [`docs/shell-user-configuration.md`](./docs/shell-user-configuration.md).
They cover CLI tools, development tooling, explicit SSH topology, and lshell.
Missing pinned packages can be supplied through typed package override options.
Secrets remain external, and these modules do not add aliases or ambient
session variables.

The `homeModules.tmux` module provides evak's tmux workflow. Import it into a
Home Manager configuration and enable the standard Home Manager option:

```nix
{
  imports = [ inputs.nixpkgs-apocrypha.homeModules.tmux ];
  programs.tmux.enable = true;
}
```

When enabled, it installs the `tmuxPlugins.yank` plugin and `wl-clipboard`,
sets Emacs mode and a blue status bar, and configures `C-Space` to enter copy
mode. Copy-mode navigation and shift-selection hotkeys are also configured;
`C-c` copies the selection through `wl-copy`. The clipboard binding assumes a
Wayland clipboard environment.

The module is an extraction of
`modules/userModules/shellModules/tmux/default.nix` from the Panoply
repository.

The `homeModules.zsh` module provides the core evak zsh setup:

```nix
{
  imports = [ inputs.nixpkgs-apocrypha.homeModules.zsh ];
  programs.zsh.enable = true;
}
```

It enables completion, autosuggestions, syntax highlighting, history substring
search, the pinned Alpine keybindings plugin, and the managed `.zprofile`.
Extended history metadata is enabled with `evak.zsh.historyMetadata = true;`.
The module deliberately does not install shell aliases or set environment
variables.

Long-running command notifications are opt-in and configurable:

```nix
{
  evak.zsh.notifications = {
    enable = true;
    thresholdSeconds = 5;
    gotifyUrl = "https://gotify.example/message";
    tokenPath = "/run/user/1000/secrets/gotify/api_token";
    fallbackCommand = "hyprctl notify 1 5000 0";
  };
}
```

Notification failures are non-fatal. The Gotify token remains an external file,
and the fallback assumes the configured desktop command is available.

The module is an extraction of
`modules/userModules/shellModules/zsh/default.nix` from the Panoply repository.

The `homeModules.vscodium` module provides the VSCodium editor configuration:

```nix
{
  imports = [ inputs.nixpkgs-apocrypha.homeModules.vscodium ];
  programs.vscode.enable = true;
}
```

It selects VSCodium with the SynthWave '84 neon CSS patch, installs the
declarative default profile and its Jinja, Python, GitHub Copilot, Nix IDE, and
SynthWave '84 extensions, and configures the editor settings, keybindings, and
tmux terminal profile. Extensions are managed declaratively through the
profile; `mutableExtensionsDir` is intentionally not enabled because it is
incompatible with Home Manager profiles. The tmux and zsh modules are separate
and must be enabled independently when needed.

The `homeModules.opencode` module provides the documented OpenCode TUI
customizations independently of the primary-agent launcher:

```nix
{
  imports = [ inputs.nixpkgs-apocrypha.homeModules.opencode ];
  evak.opencode.enable = true;
}
```

It generates `~/.config/opencode/tui.json`, the SynthWave theme,
`opencode-notifier.json`, the managed `ding.mp3`, and `opencode.json` with the
notifier, Codex quota, and quotes plugins. Completion feedback is limited to
turns longer than 10 seconds and allows notifications while focused. Gotify is
attempted first using `evak.opencode.notifications.gotifyUrl`, `tokenPath`,
and `gotifyPriority`; failed delivery falls back to `hyprctl` without affecting
OpenCode. The module assumes OpenCode, tmux, zsh, Hyprland, and a compatible
Linux audio utility are provided separately.

## Publishing

This repository follows the [NUR repository documentation](https://nur.nix-community.org/documentation/).
It must be added to NUR’s `repos.json` before it appears in the public NUR
package index.

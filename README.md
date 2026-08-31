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

## Publishing

This repository follows the [NUR repository documentation](https://nur.nix-community.org/documentation/).
It must be added to NUR’s `repos.json` before it appears in the public NUR
package index.

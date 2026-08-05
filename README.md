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

## Publishing

This repository follows the [NUR repository documentation](https://nur.nix-community.org/documentation/).
It must be added to NUR’s `repos.json` before it appears in the public NUR
package index.

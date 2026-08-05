# lshell

`lshell` is a limited shell that provides fine-grained command allow-listing.
This package is built from the upstream [`ghantoos/lshell`](https://github.com/ghantoos/lshell)
repository at a pinned revision.

## Usage

With this repository available as a NUR input or overlay:

```nix
environment.systemPackages = [ pkgs.nur.repos.nixpkgs-apocrypha.lshell ];
```

The executable is available as `lshell`.

## Package details

- Version: `0.10.10`
- License: GPL-2.0-only
- Runtime dependencies: `psutil`, `pyyaml`

# sceptre

`sceptre` is a Rust CLI for Grimoire development workflows, including
repository creation, idea processing, MCP serving, and specification-set
coordination. This package is built from the upstream
[`john-craig/sceptre`](https://github.com/john-craig/sceptre) repository at a
pinned revision.

## Usage

With this repository available as a NUR input or overlay:

```nix
environment.systemPackages = [ pkgs.nur.repos.nixpkgs-apocrypha.sceptre ];
```

The executable is available as `sceptre`:

```console
sceptre repository --help
sceptre idea --help
sceptre mcp --help
```

## Package details

- Version: `0.1.0`
- Source revision: `40fcc69d2bc38963081858d37db7be2f2ebcd554`
- License: MIT
- Supported platforms: Unix platforms supported by Nixpkgs
- Build dependencies: Rust and the locked Cargo dependency set
- Runtime integrations: Git, SSH, `gh`, and `tea` are configured by the user

Credentials, repository mappings, provider endpoints, and remote services are
not embedded in this package.

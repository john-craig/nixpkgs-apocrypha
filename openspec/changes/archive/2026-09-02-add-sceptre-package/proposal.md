## Why

Sceptre is a Rust CLI for Grimoire development workflows, including repository creation, idea processing, MCP serving, and specification-set coordination. Packaging it in this repository will make the tool reproducibly available through the existing NUR/flake package interfaces instead of requiring a separate local build workflow.

## What Changes

- Add a Nix package under `pkgs/sceptre` built from the upstream `john-craig/sceptre` repository.
- Pin the upstream source revision and Cargo dependency set through standard Rust package metadata.
- Expose the package through `default.nix`, flake `legacyPackages`, and flake `packages` outputs.
- Preserve the upstream `sceptre` executable and verify its CLI starts and reports help/version information.
- Add package documentation covering installation, usage, source revision, license, and runtime/build dependencies.
- Add focused package checks for buildability, binary output, metadata, and basic command execution.

## Capabilities

### New Capabilities

- `sceptre-package`: Reproducible Nix packaging and public flake/NUR exposure of the Sceptre Rust CLI.

### Modified Capabilities

None.

## Impact

- Affected files: `pkgs/sceptre`, `default.nix`, `flake.nix`, package documentation, and package checks.
- New upstream source: `https://github.com/john-craig/sceptre`.
- Build system: Rust/Cargo via the repository's existing Nix package conventions.
- Public outputs: a new `sceptre` package and executable; no existing package or module behavior changes.
- Runtime integrations: Sceptre may invoke configured `gh`, `tea`, and Git/SSH tooling at runtime, but those external credentials and services remain consumer-provided.

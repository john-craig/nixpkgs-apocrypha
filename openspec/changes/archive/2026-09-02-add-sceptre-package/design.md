## Context

See `proposal.md` for motivation. This repository currently exposes one locally packaged Python application through `default.nix` and the flake package outputs. Sceptre is an upstream Rust CLI with a Cargo lockfile and a command-line binary.

## Goals / Non-Goals

**Goals:**

- Package the upstream Sceptre CLI reproducibly using standard Nix Rust tooling.
- Expose it consistently with the existing package and flake interfaces.
- Verify the produced binary and basic help behavior without requiring provider credentials or remote services.
- Keep runtime Git, GitHub, Gitea, and credential configuration under the consumer's control.

**Non-Goals:**

- Changing Sceptre source code or upstream CLI behavior.
- Packaging or configuring `gh`, `tea`, Git, SSH, MCP servers, or remote providers as part of Sceptre.
- Adding a Home Manager module or shell integration.
- Embedding credentials, repository mappings, or service endpoints.

## Decisions

### Use `buildRustPackage`

Use the repository's Nix package style with `rustPlatform.buildRustPackage`, `fetchFromGitHub`, a pinned revision/hash, and the upstream `Cargo.lock`. This keeps the derivation conventional and lets Cargo dependency vendoring remain content-addressed.

Alternative considered: build through the upstream flake. Rejected because the repository should expose a self-contained package derivation and avoid importing unrelated upstream development outputs.

### Preserve the upstream binary name

Set the package's `mainProgram` and build metadata to the actual upstream binary name, confirming it from `Cargo.toml` during implementation rather than assuming the repository name is the binary name.

### Keep runtime integrations external

Do not add wrappers, environment files, credentials, or provider-specific runtime dependencies. Sceptre's documented use of Git, `gh`, `tea`, and SSH remains runtime behavior supplied by the user's environment.

### Verify without remote mutation

Use build-time import/compile checks and a local `--help` invocation. Tests must not create repositories, branches, ideas, MCP sessions, or provider records.

## Risks / Trade-offs

- [Upstream repository metadata may change] -> Pin an immutable revision, use the lockfile, and record the source version/hash in package documentation.
- [Binary name or build layout differs from expectation] -> Inspect Cargo metadata before finalizing the derivation and test the installed output.
- [Runtime commands require external tools] -> Keep those tools out of the build contract and document them as optional runtime prerequisites.
- [Rust dependency build cost] -> Reuse Cargo lock data and standard Nix substituters where available.

## Migration Plan

1. Inspect upstream Cargo metadata, license, binary target, and build instructions.
2. Add the pinned package derivation and expose it in repository outputs.
3. Add package documentation and focused build/help checks.
4. Run formatting, package build, and full flake checks.

Rollback is removal of the new package derivation, output, documentation, and check; no persisted data or consumer configuration migration is required.

## Open Questions

- The exact upstream release/version and license expression should be taken from the pinned source metadata during implementation; this does not change the package interface or acceptance criteria.

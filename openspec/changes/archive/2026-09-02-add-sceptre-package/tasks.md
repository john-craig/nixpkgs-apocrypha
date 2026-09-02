## 1. Upstream Metadata

- [x] 1.1 Inspect the pinned Sceptre source revision, `Cargo.toml`, `Cargo.lock`, binary target, license, and supported platforms; verify the selected metadata matches upstream.
- [x] 1.2 Determine the package's required build inputs and whether tests can run offline; verify the dependency plan does not require runtime provider credentials.

## 2. Package Definition

- [x] 2.1 Add `pkgs/sceptre/default.nix` using `rustPlatform.buildRustPackage`, `fetchFromGitHub`, the pinned revision/hash, and Cargo lockfile; verify the derivation evaluates without mutable references.
- [ ] 2.2 Configure package metadata, supported platforms, and `mainProgram`; verify the installed output contains the expected Sceptre executable.
- [x] 2.3 Expose `sceptre` from `default.nix` and the flake package outputs; verify `nix eval` resolves the package on supported systems.

## 3. Verification And Documentation

- [x] 3.1 Add focused package checks for derivation metadata, executable presence, `sceptre --help`, and absence of embedded credentials; verify checks do not contact or mutate remote services.
- [x] 3.2 Add `pkgs/sceptre/README.md` and update the repository README with installation, usage, source, license, runtime prerequisites, and package commands; verify documented commands and paths match the package outputs.
- [ ] 3.3 Run formatting, the focused Sceptre build/check, full `nix flake check`, and `git diff --check`; inspect the final diff for unrelated changes.

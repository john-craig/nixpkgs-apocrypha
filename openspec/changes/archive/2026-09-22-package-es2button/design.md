## Context

Panoply's existing derivation is a small `rustPlatform.buildRustPackage` package for the `janrueth/es2button` GitHub repository. It builds the `es2button` workspace member with `pkg-config`, bindgen support, and `libusb1`, and is already pinned to revision `624df7ac087cd7e3ca5ca79d7e811c68e5fca8d5`. This repository exposes packages from `default.nix`, which the flake maps to both `legacyPackages` and filtered `packages`, while `overlay.nix` derives overlay attributes from the same set.

## Goals / Non-Goals

**Goals:**

- Reuse the known-good upstream revision and dependency hashes from Panoply.
- Keep the derivation portable within the repository's normal `pkgs/` package layout and automatic exports.
- Make the package's Linux-only support and Epson Scan 2 runtime boundary explicit.
- Add a focused check that catches missing exposure or accidental package drift.

**Non-Goals:**

- Packaging Epson Scan 2 or any other proprietary scanner backend.
- Adding a scanner service, udev rules, Home Manager module, or NixOS module to this repository.
- Replacing or modifying Panoply's existing package.
- Generalizing the package discovery mechanism beyond adding the package directory and NUR entry.

## Decisions

### Copy the pinned package into the NUR package namespace

Add `pkgs/es2button/default.nix` using the Panoply derivation's fixed source revision, source hash, Cargo hash, build subdirectory, and native/build inputs. This is preferable to importing the sibling repository because NUR evaluation must remain self-contained and consumers should not inherit a local filesystem dependency.

### Use the existing package exposure path

Add the package to `default.nix` alongside the current explicit package attributes. No separate flake package declaration or overlay-specific implementation is needed: `legacyPackages` imports `default.nix`, `packages` filters its derivations, and `overlay.nix` exports non-reserved attributes from that same result. A focused check should verify all public paths rather than duplicating export logic.

### Retain upstream Cargo build behavior

Use `buildAndTestSubdir = "es2button"` and `rustPlatform.bindgenHook` exactly as in Panoply. The workspace layout and bindgen-generated libusb bindings are upstream build constraints; switching to a generic `buildRustPackage` root or omitting bindgen could produce a derivation that evaluates but does not build.

### Document the proprietary runtime boundary, do not wrap it

Keep the package output limited to the listener. Epson Scan 2's dynamic libraries are vendor software and are expected to be provisioned by the consuming host. Adding an FHS wrapper or runtime path option in this NUR would couple a reusable package to one host's proprietary installation layout and exceed the requested packaging scope.

## Risks / Trade-offs

- **The pinned upstream revision may stop building with current nixpkgs Rust tooling** -> Build the package in the focused check and retain the exact revision and hashes until an intentional update is made.
- **The package may be evaluated on non-Linux systems** -> Set Linux-only metadata and verify the check is gated or evaluated against the supported system.
- **Consumers may assume Epson Scan 2 is included** -> Keep the vendor boundary in package documentation and metadata-facing documentation, and test that no vendor runtime files are introduced.
- **Automatic package discovery may expose the package before explicit flake tests are added** -> Verify `default.nix`, `legacyPackages`, `packages`, and overlay attributes in the change's focused check.

## Migration Plan

1. Add the derivation and explicit NUR package attribute, then add a focused build/evaluation check.
2. Build the package and run the focused check on the supported Linux system.
3. Consumers can replace duplicated or sibling-repository derivations with `pkgs.es2button` after the NUR revision is available.

Rollback is removing the package attribute, derivation, documentation, and focused check; no state migration or runtime service change is required.

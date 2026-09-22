## Why

The `es2button` package used by Panoply's Epson scanner workflow is not available from this NUR, so consumers must duplicate its pinned Rust derivation or depend on the separate Panoply repository. Packaging it here provides a reusable, independently consumable Nix package while keeping the source and Cargo dependencies reproducible.

## What Changes

- Add a Linux-only `es2button` Rust package based on the pinned `janrueth/es2button` revision used by Panoply.
- Build the package with the required `pkg-config`, bindgen, and `libusb1` inputs and expose its `es2button` executable as the main program.
- Export the derivation through the NUR's `default.nix`, flake `legacyPackages`/`packages`, and overlay surfaces using the repository's existing package conventions.
- Add focused package evaluation/build checks for the executable, metadata, platform restriction, and reproducible source/dependency hashes.
- Document that the package does not redistribute Epson Scan 2 vendor software or its runtime libraries; those remain an external host prerequisite.

## Capabilities

### New Capabilities

- `es2button-package`: Provide a reproducible Linux Nix package for the Epson scanner button listener and its supported runtime boundary.

### Modified Capabilities

## Impact

- Adds `pkgs/es2button/default.nix` and package-facing documentation or checks as needed.
- Changes the NUR package set and overlay so consumers can use `pkgs.es2button`, `legacyPackages.<system>.es2button`, `packages.<system>.es2button`, or the overlay-provided attribute.
- Adds a Rust build-time dependency closure on `libusb1`, `pkg-config`, and `rustPlatform.bindgenHook`.
- Does not package, fetch, or install Epson Scan 2 proprietary software; runtime integration remains the responsibility of the consuming scanner module or host.

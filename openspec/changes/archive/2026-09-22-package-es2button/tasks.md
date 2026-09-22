## 1. Package Derivation

- [x] 1.1 Add `pkgs/es2button/default.nix` using the Panoply derivation's pinned `janrueth/es2button` revision, source hash, Cargo hash, workspace subdirectory, Linux metadata, and `pkg-config`/bindgen/`libusb1` inputs; verify the derivation evaluates without undeclared dependencies.
- [x] 1.2 Add package documentation describing the upstream source, reproducibility boundary, and external Epson Scan 2 runtime prerequisite; verify it does not claim to redistribute vendor software.

## 2. NUR Exposure

- [x] 2.1 Add `es2button` to `default.nix` and verify `nix eval` resolves the package from the legacy package set.
- [x] 2.2 Verify the automatic flake package and overlay paths expose the same `es2button` derivation on Linux without adding duplicate export logic.

## 3. Verification

- [x] 3.1 Add a focused flake check that validates the package executable, main program metadata, Linux platform metadata, pinned source/dependency behavior, and absence of Epson Scan 2 vendor files; verify the check passes without network access after dependencies are fixed.
- [x] 3.2 Build `es2button` on the supported Linux system, run `git diff --check`, and run the relevant flake checks; verify failures are resolved before marking the change complete.

## Purpose

Provide a reproducible Nix package for the Linux Epson scanner button listener so downstream configurations can consume the same pinned build without duplicating packaging logic.

## ADDED Requirements

### Requirement: Reproducible es2button package

The package set SHALL provide an `es2button` derivation that builds the `janrueth/es2button` source from a fixed revision with fixed source and Cargo dependency hashes, and SHALL expose an executable named `es2button`.

#### Scenario: Consumer builds the package

- **WHEN** a Linux consumer evaluates and builds `es2button`
- **THEN** the build SHALL complete from the pinned source and vendored/fixed dependency inputs without requiring network access during the build
- **AND** the resulting output SHALL contain an executable at `bin/es2button`

#### Scenario: Package metadata is inspected

- **WHEN** a consumer inspects the derivation metadata
- **THEN** it SHALL identify the Epson scanner button use case, the upstream project homepage, the MIT license, Linux platform support, and `es2button` as the main program

### Requirement: NUR package exposure

The package SHALL be available through the repository's standard package exposure surfaces, including the legacy package set, per-system flake packages, and the overlay, using the attribute name `es2button`.

#### Scenario: Consumer uses the flake package

- **WHEN** a consumer evaluates `legacyPackages.<system>.es2button` or `packages.<system>.es2button`
- **THEN** the attribute SHALL resolve to the same buildable package

#### Scenario: Consumer uses the overlay

- **WHEN** a consumer applies the NUR overlay to a compatible Linux nixpkgs package set
- **THEN** `pkgs.es2button` SHALL resolve to the packaged derivation

### Requirement: Vendor runtime boundary

The package SHALL not redistribute Epson Scan 2 proprietary software or its libraries, and its metadata or documentation SHALL state that those vendor libraries are an external runtime prerequisite for applications using the listener.

#### Scenario: Consumer installs the package without vendor software

- **WHEN** a consumer builds or installs `es2button`
- **THEN** the output SHALL contain only the open-source listener and its declared runtime closure
- **AND** the package SHALL not fetch or install Epson Scan 2 vendor files

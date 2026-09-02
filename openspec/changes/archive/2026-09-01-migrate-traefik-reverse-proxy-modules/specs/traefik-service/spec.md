## Purpose

Provide a standalone NixOS capability for running Traefik with explicit storage,
logging, entry-point, ACME, and provider configuration inputs.

## ADDED Requirements

### Requirement: Public Traefik module

The repository SHALL expose a standalone NixOS module for configuring the Traefik service without requiring Panoply modules or option paths.

#### Scenario: Consumer imports the module

- **WHEN** a NixOS configuration imports the exported Traefik module
- **THEN** evaluation SHALL succeed without importing Panoply

### Requirement: Persistent Traefik service

When enabled, the module SHALL configure Traefik with an explicit data directory, static configuration, dynamic configuration, and persistent ACME storage.

#### Scenario: Traefik is enabled

- **WHEN** the module is enabled
- **THEN** the resulting system SHALL enable Traefik and preserve configured data and dynamic configuration across service restarts

### Requirement: HTTP and HTTPS entry points

The module SHALL support HTTP-to-HTTPS redirection and explicit HTTPS entry-point configuration, including trusted proxy and proxy protocol ranges.

#### Scenario: HTTP traffic is received

- **WHEN** a request arrives through the configured HTTP entry point
- **THEN** Traefik SHALL redirect it to the configured HTTPS entry point

### Requirement: ACME DNS challenge credentials

The module SHALL accept an external credentials file path and SHALL pass that path to Traefik without embedding credential contents in the repository.

#### Scenario: External DNS credentials are configured

- **WHEN** a credentials file path is configured
- **THEN** Traefik SHALL reference the path and the evaluated configuration SHALL contain no credential value

### Requirement: Optional container provider

The module SHALL optionally configure Podman/Docker-provider discovery using an explicit socket path, proxy network, and `exposedByDefault` policy.

#### Scenario: Container integration is disabled

- **WHEN** container integration is disabled
- **THEN** the module SHALL not require Podman, a container socket, or a proxy network

#### Scenario: Container integration is enabled

- **WHEN** container integration is enabled
- **THEN** Traefik SHALL be configured to inspect the selected container socket and use the configured proxy network

### Requirement: Disabled behavior

The module SHALL avoid installing or configuring Traefik-specific services, files, and assertions when disabled.

#### Scenario: Traefik is disabled

- **WHEN** the module is imported with enablement disabled
- **THEN** it SHALL not enable Traefik or create Traefik-specific generated configuration

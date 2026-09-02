# traefik-jit-access Specification

## Purpose

Provide temporary IP/CIDR-scoped access overrides for selected Traefik
hostnames, with secure generated state and automatic expiration.

## Requirements

### Requirement: Public JIT access module

The repository SHALL expose a standalone NixOS module for Traefik JIT access without requiring Panoply-specific options.

#### Scenario: Consumer imports the module

- **WHEN** a NixOS configuration imports the exported JIT access module
- **THEN** evaluation SHALL succeed without Panoply modules

### Requirement: Grant and revoke access

The module SHALL provide an operator command supporting `grant`, `revoke`, `list`, and `prune` operations for configured Traefik hostnames.

#### Scenario: An operator grants access

- **WHEN** an operator supplies an IP or CIDR, duration, and hostname
- **THEN** the command SHALL record the grant and generate a Traefik override route

#### Scenario: An operator revokes access

- **WHEN** an operator revokes a hostname
- **THEN** its grant metadata and generated override route SHALL be removed

### Requirement: Temporary IP allowlisting

Generated override routes SHALL apply an IP allowlist containing active grants and SHALL have priority above the original matching route.

#### Scenario: A grant is active

- **WHEN** a request matches the hostname and originates within an active source range
- **THEN** Traefik SHALL route the request through the generated override

### Requirement: Route discovery and validation

The module SHALL discover matching active Traefik routes from a configurable API endpoint and SHALL fail clearly when no usable route matches the requested hostname.

#### Scenario: No matching route exists

- **WHEN** a grant targets an unknown hostname
- **THEN** the command SHALL fail without generating an override

### Requirement: Expiration and pruning

The module SHALL record expiration timestamps, provide a configurable prune interval, and remove expired grants and routes.

#### Scenario: A grant expires

- **WHEN** pruning runs after a grant expires
- **THEN** the expired grant and its generated route SHALL be removed

### Requirement: Secure generated state

JIT metadata, lock files, and generated dynamic configuration SHALL use restrictive permissions, Traefik-readable ownership where required, and atomic replacement where practical.

#### Scenario: Generated state is written

- **WHEN** a grant or prune operation writes state
- **THEN** the resulting files SHALL not be world-readable and concurrent operations SHALL be serialized

### Requirement: Disabled behavior

The module SHALL not install the JIT command, timer, activation state, or Traefik provider changes when disabled.

#### Scenario: JIT access is disabled

- **WHEN** the module is imported with enablement disabled
- **THEN** no JIT command or prune timer SHALL be present

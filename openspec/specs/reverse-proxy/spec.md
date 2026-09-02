# reverse-proxy Specification

## Purpose

Provide declarative reverse-proxy routes for local, internal, public, and
container-backed services without depending on Panoply's host option hierarchy.

## Requirements

### Requirement: Public reverse-proxy module

The repository SHALL expose a standalone NixOS reverse-proxy module with repository-owned options.

#### Scenario: Consumer imports the module

- **WHEN** a NixOS configuration imports the exported reverse-proxy module
- **THEN** evaluation SHALL succeed without Panoply-specific options

### Requirement: Explicit upstream routes

The module SHALL accept routes with a hostname and upstream URL, and SHALL support explicit entry points, TLS resolver, priority, path prefix, and middleware settings.

#### Scenario: A route is configured

- **WHEN** an enabled route specifies a hostname and upstream URL
- **THEN** Traefik SHALL receive a router and load-balancer service for that route

### Requirement: Internal route restrictions

The module SHALL support a configurable internal access rule that is applied to routes marked internal.

#### Scenario: An internal route is configured

- **WHEN** a route is marked internal
- **THEN** its generated rule SHALL include the configured internal restriction

### Requirement: External authentication middleware

The module SHALL support an optional authentication middleware for routes marked external.

#### Scenario: An external route has authentication configured

- **WHEN** an external route and middleware name are configured
- **THEN** the generated router SHALL reference that middleware

### Requirement: Container network integration

The module SHALL optionally create or use a named proxy network and SHALL provide the network name needed by container labels and provider discovery.

#### Scenario: A proxied container is configured

- **WHEN** container integration is enabled for a route
- **THEN** the route SHALL use the configured proxy network and the upstream container SHALL be reachable through it

### Requirement: Safe route validation

The module SHALL fail evaluation with a clear error when an enabled route lacks a hostname, upstream URL, or required TLS/resolver input.

#### Scenario: A route is incomplete

- **WHEN** an enabled route omits a required value
- **THEN** evaluation SHALL fail and identify the invalid route

### Requirement: Disabled behavior

The module SHALL not create routes, networks, or proxy-specific service configuration when disabled.

#### Scenario: Reverse proxy is disabled

- **WHEN** the module is imported with enablement disabled
- **THEN** no reverse-proxy route or network configuration SHALL be generated

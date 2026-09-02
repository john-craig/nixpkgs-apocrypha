## Why

Traefik and the reusable reverse-proxy configuration currently depend on Panoply's private host option hierarchy, SOPS secret layout, Podman topology, and implicit service-proxy settings. Extracting these modules into nixpkgs-apocrypha will make them independently reusable while preserving the current homeserver deployment behavior.

## What Changes

- Add standalone NixOS modules for Traefik service configuration, declarative reverse-proxy routes, and temporary Traefik JIT access.
- Replace Panoply-specific option paths with repository-owned options and explicit inputs for secrets, resolver names, trusted proxy ranges, networks, and routes.
- Preserve HTTPS redirection, ACME DNS challenge support, persistent state, access logging, Podman provider integration, and JIT grant/revoke/prune behavior.
- Add focused NixOS evaluation and VM test coverage, exports, and migration documentation.
- Keep unrelated self-hosted service and application modules out of scope.

## Capabilities

### New Capabilities

- `traefik-service`: Standalone Traefik service configuration with explicit persistence, logging, entry-point, ACME, and provider inputs.
- `reverse-proxy`: Declarative host-to-upstream routes with optional internal rules, authentication middleware, TLS, and container-network integration.
- `traefik-jit-access`: Temporary IP/CIDR-scoped access overrides for selected Traefik hostnames, including secure state, expiration, and pruning.

### Modified Capabilities

None.

## Impact

- New NixOS modules under `nixos-modules/` and exports in `nixos-modules/default.nix`, `default.nix`, and `flake.nix`.
- New focused evaluations and NixOS VM tests under `tests/`.
- Panoply consumers will need to replace `hostServices.serviceProxies` and `hostServices.networkServices.traefikJitAccess` imports with the new modules and explicit options.
- Secret values remain outside this repository; consumers provide paths to DNS credentials and other sensitive files.

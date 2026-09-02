## 1. Traefik Service Module

- [x] 1.1 Create the repository-owned Traefik module structure and verify it evaluates without Panoply imports.
- [x] 1.2 Define explicit enablement, data-directory, logging, static-configuration, dynamic-configuration, and entry-point options; verify defaults through a Nix evaluation.
- [x] 1.3 Port HTTPS redirection, access logging, persistent ACME storage, trusted proxy settings, and external DNS credential-path handling; verify generated service configuration contains no secret contents.
- [x] 1.4 Add opt-in container-provider configuration, socket permissions, and proxy-network inputs; verify disabled mode does not reference Podman.
- [x] 1.5 Add focused Traefik evaluation coverage for enabled and disabled behavior and verify it passes.

## 2. Reverse Proxy Module

- [x] 2.1 Define structured route options for hostname, upstream URL, route class, entry points, TLS resolver, priority, path prefix, and middleware; verify incomplete routes fail with actionable assertions.
- [x] 2.2 Generate Traefik routers and services for explicit routes; verify internal, external, and public route rules and middleware references in evaluated dynamic configuration.
- [x] 2.3 Integrate optional named container-network configuration with the Traefik provider; verify a proxied container can join the configured network in a VM test.
- [x] 2.4 Add reverse-proxy evaluation and VM coverage for route generation, access restrictions, and disabled behavior.

## 3. Traefik JIT Access Module

- [x] 3.1 Port the JIT access command and supporting normalization, duration, discovery, metadata, and rendering helpers; verify the command exposes grant, revoke, list, and prune operations.
- [x] 3.2 Replace Panoply-specific option lookups with explicit API endpoint, directory, priority, router-prefix, rule-fragment, and middleware-prefix options; verify standalone evaluation.
- [x] 3.3 Preserve locking, restrictive permissions, Traefik group ownership, and atomic state/configuration replacement; verify generated files are not world-readable.
- [x] 3.4 Add the expiration-prune service and timer with a configurable interval; verify expired state and routes are removed.
- [x] 3.5 Add a NixOS VM test for denied access, temporary grant success, revoke behavior, and post-expiration pruning.

## 4. Exports, Migration, and Verification

- [x] 4.1 Export the Traefik, reverse-proxy, and JIT modules from `nixos-modules/default.nix`, `default.nix`, and the flake output; verify every public module resolves.
- [x] 4.2 Add documentation mapping Panoply option paths and external secret references to the new explicit options; verify no private credentials or addresses are copied into reusable module code.
- [x] 4.3 Update the Panoply consumer configuration to import the new modules and pass equivalent resolver, network, route, trusted-range, and secret-path values; verify duplicate old services are disabled.
- [x] 4.4 Run focused evaluations and VM tests, `nix flake check path:$PWD`, and strict OpenSpec validation; verify existing repository checks remain green.

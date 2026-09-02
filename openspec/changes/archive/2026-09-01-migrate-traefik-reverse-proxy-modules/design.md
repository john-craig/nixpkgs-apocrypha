## Context

Panoply currently provides Traefik through `modules/hostModules/serviceProxies` and temporary access through `modules/hostModules/networkModules/traefikJitAccess`. The former combines Traefik, ACME, logging, Podman socket permissions, dynamic extra proxies, and a shared container network. The latter discovers live routers through the Traefik API and writes file-provider overrides, while reading Panoply-specific internal-rule options.

The destination repository already has an empty `nixos-modules` namespace and a custom package, but no system-service modules. See `proposal.md` and the three capability specs for the intended public contract.

## Goals / Non-Goals

**Goals:**

- Preserve observable Traefik and JIT access behavior while removing Panoply option-tree coupling.
- Keep core Traefik, reverse-proxy routes, and JIT access independently enableable.
- Make secrets, network names, trusted ranges, API endpoints, and route definitions explicit inputs.
- Keep generated state secure and make the modules evaluable without private infrastructure.
- Provide focused evaluation and VM coverage for the exported public modules.

**Non-Goals:**

- Migrating unrelated self-hosted service and application modules.
- Migrating application-specific service modules or their dashboard definitions.
- Embedding SOPS integration, DNS credentials, private addresses, or host-specific routes in this repository.
- Replacing nixpkgs' underlying `services.traefik` implementation.

## Decisions

- **Use standalone NixOS modules.** These capabilities configure system services, users/groups, sockets, timers, and `/var/lib` state, so they belong under `nixosModules`, not `homeModules`.
- **Use three public modules.** Core Traefik, route generation, and JIT access have separate lifecycle and dependency needs. Splitting them avoids enabling Podman or a prune timer for consumers that only need one capability.
- **Build on `services.traefik`.** The modules will compose with nixpkgs' Traefik options and use `staticConfigOptions`, `dynamicConfigOptions`, `environmentFiles`, and service overrides instead of maintaining a competing service definition.
- **Use explicit repository-owned options.** Options will be namespaced under `services.apocrypha` and will not inspect Panoply host option paths or `config.sops` paths. Consumers can map their existing secret manager to a file path.
- **Keep route inputs structured.** Route submodules will represent hostname, upstream, access class, entry points, TLS, priorities, and middleware directly. This avoids preserving the old untyped `extraProxies` list as the long-term API.
- **Make container integration opt-in.** Podman socket ACLs, provider configuration, and proxy-network handling will be gated by a container option. The default route-only use case must not require Podman.
- **Port JIT scripts with configurable integration points.** The existing normalization, router discovery, metadata, locking, and rendering behavior will be retained, while API endpoint, dynamic directory, state directory, router prefix, rule fragments, and middleware prefixes become explicit options.
- **Test without real ACME.** VM tests will use local HTTP or insecure dashboard settings and a test backend. Evaluation will assert that secret contents are never embedded; no live DNS provider or private network is required.

Alternatives considered:

- Copying the Panoply modules unchanged was rejected because it would preserve private option paths and secret-manager coupling.
- A single monolithic module was rejected because route generation and JIT access should be independently deployable.
- A Home Manager implementation was rejected because the behavior owns NixOS services, system groups, timers, and privileged state.

## Risks / Trade-offs

- **Traefik option schema changes across nixpkgs revisions** -> Use the repository's pinned nixpkgs input and focused evaluations; avoid unsupported assumptions outside the existing module interface.
- **Secret-file ownership differs between consumers** -> Require explicit paths and document ownership requirements instead of creating secret-manager-specific code.
- **JIT route discovery depends on Traefik API response shape** -> Preserve support for both list and map router responses and test representative raw-data payloads.
- **Generated routes can accidentally bypass authentication or internal restrictions** -> Require explicit access class semantics, preserve middleware stripping only through configurable lists, and test generated rules and priorities.
- **Podman socket access is sensitive** -> Keep provider integration opt-in, configure restrictive ACLs, and test disabled behavior separately.
- **Changing option names breaks Panoply consumers** -> Provide an explicit migration table and update consumers in a separate implementation step without retaining compatibility aliases in the reusable module.

## Migration Plan

1. Implement and evaluate the core Traefik module.
2. Implement reverse-proxy routes and optional container integration.
3. Implement JIT access and its prune timer against the new route/API options.
4. Export all modules and run focused evaluations and VM tests.
5. Update Panoply host configurations to import the new modules and map existing secret paths, resolver/network values, trusted ranges, and routes.
6. Disable the old Panoply modules only after generated configuration and service behavior have been compared.
7. Roll back by restoring the old imports and removing new enablement; remove only generated JIT state if cleanup is needed.

## Open Questions

- None that change the proposed public contract. Exact option names and the final route submodule shape can be settled during implementation while preserving the requirements above.

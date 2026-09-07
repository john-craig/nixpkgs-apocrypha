## Context

See `proposal.md` for motivation. The repository's flake currently overlays
`opencode-nix`, whose pinned OpenCode source evaluates as `1.2.10-f07e877`.
Panoply's stabilized `evak` profile uses the `nixpkgsUnstable` OpenCode package,
which evaluates as `1.18.21`. The `opencode-agents` Home Manager module defaults
to `pkgs.opencode` but already supports an explicit `opencodePackage` override.

## Goals / Non-Goals

**Goals:**

- Make the repository's default OpenCode package evaluate to `1.18.21`.
- Ensure the agent runner consumes the same default package that the package
  compatibility check verifies.
- Preserve explicit package overrides for consumers with independently managed
  nixpkgs inputs.
- Provide a clear migration path for the NixOS user module.

**Non-Goals:**

- Migrating or expanding MCP definitions.
- Reproducing Panoply's global OpenCode settings, permissions, notifications,
  launchers, diagnostic commands, or OpenChamber services.
- Changing agent prompts, role selection, generated environment files, or
  runtime server behavior.

## Decisions

### Use the repository's existing package boundary

Update the existing `opencode`/`opencode-nix` input lock state or package
overlay source so the established `pkgs.opencode` boundary produces version
`1.18.21`. Keep the existing overlay as the authoritative package provider and
avoid adding a second ad hoc derivation or vendoring Panoply's package code.

Alternative considered: import Panoply's `nixpkgsUnstable` as a new flake input.
Rejected because it would couple this repository to a consumer repository's
package-set choice and create two competing OpenCode package sources.

Alternative considered: make the Home Manager module download or construct a
package internally. Rejected because Home Manager modules should consume the
package set supplied by the consumer rather than manage package provenance.

### Keep the existing explicit override

Retain `evak.opencode-agents.opencodePackage` as the escape hatch for consumers
whose package set differs from the repository's default. The default path is
version-checked; explicit overrides remain intentional consumer policy and are
used by the runner unchanged.

Alternative considered: reject every explicit package whose version is not
`1.18.21`. Rejected because consumers may need a controlled temporary version
for testing or an independently packaged system, and the existing module
already defines an explicit override contract.

### Verify version and runner wiring independently

Add a package-level check that evaluates `pkgs.opencode.version`, and extend
Home Manager module tests to verify the default and explicit package paths. The
NixOS user-module fixture will verify that the package override is passed into
the generated profile without changing the module's required enables.

### Treat the version as a compatibility target

Document `1.18.21` as the supported Panoply compatibility target rather than
claiming that all future OpenCode versions are equivalent. A later upgrade must
update the target, lock state, and checks together.

## Risks / Trade-offs

- [The required version may not be available through the current `opencode-nix` source] → Resolve the package input/overlay lock state during implementation and stop rather than silently selecting another version.
- [Updating OpenCode may change CLI or configuration behavior] → Keep the change scoped to package alignment, run existing checks, and do not claim MCP or global-configuration parity.
- [Consumers use independent nixpkgs inputs] → Preserve and document the explicit `opencodePackage` override.
- [A version string alone may not capture runtime compatibility] → Test the actual package executable and the generated runner's package path in addition to checking the version attribute.

## Migration Plan

1. Update the repository package source/lock state and verify the default
   package evaluates as `1.18.21`.
2. Run the focused OpenCode agent and NixOS-user checks, then the full flake
   checks.
3. Consumers using the repository overlay receive the aligned default package
   after updating their flake lock state.
4. Consumers with their own package set explicitly pass their `1.18.21`
   package through `evak.opencode-agents.opencodePackage`.
5. Roll back by reverting the package input/overlay lock update; no generated
   user data or configuration migration is required.

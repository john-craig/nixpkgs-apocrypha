## Why

Panoply's stabilized `evak` OpenCode configuration evaluates OpenCode
`1.18.21`, while this repository currently evaluates `pkgs.opencode` as
`1.2.10-f07e877`. A consumer switching to the repository's OpenCode agent home
module could therefore change the runtime and MCP protocol behavior even when
the generated configuration is otherwise equivalent.

## What Changes

- Align the repository-provided OpenCode package used by the OpenCode home modules with Panoply's supported `1.18.21` version.
- Define one authoritative package/version contract for `pkgs.opencode`, the `opencode-agents` runner, and the OpenCode package used in module tests.
- Add evaluation and package checks that fail when the resolved OpenCode version drifts from the compatibility target.
- Document how consumers with an independent package set can provide the aligned package explicitly to `opencode-agents`.
- Preserve existing OpenCode configuration, agent definitions, MCP declarations, permissions, notifications, launchers, and OpenChamber behavior unchanged.

## Capabilities

### New Capabilities

- `opencode-package-compatibility`: Establishes the supported OpenCode package version and ensures the repository's OpenCode home-module runner uses it.

### Modified Capabilities

None.

## Impact

- The flake inputs and/or package overlay that provide `pkgs.opencode` may need to change to produce the aligned version.
- `home-modules/opencode-agents` and its tests will gain an explicit package-version compatibility contract.
- The NixOS user module's documented package wiring will be updated, but its user options and Home Manager composition will not otherwise change.
- Consumers may need to refresh their lock file or explicitly pass an aligned `opencodePackage` when their own nixpkgs set does not provide `1.18.21`.
- No MCP inventory, MCP environment mapping, global OpenCode settings, permissions, notification behavior, OpenCode server, or OpenChamber integration is included in this change.

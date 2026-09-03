## Why

The `opencode-agent` runner is currently installed only through the Home Manager
module, so a fresh checkout cannot use the repository's declarative agents until
the configuration has first been deployed. Exposing the runner as a flake
package would make agent sessions available for bootstrapping, testing, and
temporary use directly from the checkout while retaining generated environment
configuration as a separate concern.

## What Changes

- Add a flake package for the `opencode-agent` runner script.
- Make the runner locate or accept generated agent environments without requiring
  the Home Manager-installed command.
- Preserve the existing `--agent`, `--directory`/`--dir`, and `--prompt` interface
  and validation behavior.
- Support selecting an environment root or configuration location for direct
  flake usage, with a clear default and actionable errors when an environment is
  unavailable.
- Expose the package through the repository's standard package interfaces and
  document `nix run`/`nix build` usage.
- Add checks proving direct execution, argument forwarding, agent validation, and
  absence of embedded credentials.

## Capabilities

### New Capabilities

- `opencode-agent-flake-runner`: Execute a configured OpenCode agent directly
  from the flake without first deploying the Home Manager module.

### Modified Capabilities

- `openspec/specs/opencode-agent-runner`: Extend the runner contract to cover
  flake-provided execution in addition to the installed command.

## Impact

- Affected files include the package definitions, flake/default package exports,
  runner tests, and OpenCode agent documentation.
- The package depends on the existing OpenCode executable at runtime and on a
  discoverable generated environment or explicitly supplied environment root.
- Direct execution must not copy credentials or machine-specific configuration
  into the Nix store, and it must not change the existing Home Manager module's
  activation behavior.

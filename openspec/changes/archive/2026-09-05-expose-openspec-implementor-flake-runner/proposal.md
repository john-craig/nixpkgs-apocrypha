## Why

The OpenSpec implementor workflow is currently generated only by its Home
Manager module. A user must deploy the module before they can run the command,
which makes bootstrapping and repository-local testing unnecessarily difficult.
The repository already exposes the `opencode-agent` runner as a flake package,
so the implementor should be available through the same direct flake interface.

## What Changes

- Extract the implementor command construction into reusable package logic
  rather than maintaining a second flake-specific script.
- Add an `openspec-implementor` flake package with the same CLI and workflow
  behavior as the Home Manager-installed command.
- Expose the package through `default.nix`, `legacyPackages`, and flake
  `packages` outputs.
- Make `nix run .#openspec-implementor -- --help` and equivalent remote-flake
  invocations work without Home Manager activation.
- Include the runtime OpenCode, OpenSpec, Git, JSON, and provider CLI
  dependencies needed by the direct runner while retaining external provider
  credentials.
- Preserve Home Manager package overrides and behavior by making the module
  consume the same reusable runner implementation.
- Add package checks for direct invocation, dependency resolution, behavior
  parity, and absence of embedded credentials.

## Capabilities

### New Capabilities

- `openspec-implementor-flake-runner`: Run the OpenSpec implementation workflow
  directly from this repository's flake.

## Impact

- Adds a package definition and package exports.
- Refactors the existing Home Manager module to reuse the package or shared
  runner construction without changing its public command or options.
- The direct package includes the OpenCode executable and generated agent
  environments needed by `opencode-agent`; provider authentication remains
  user-supplied at runtime.
- Nix evaluation and checks must construct the package for every supported
  system without depending on a deployed Home Manager profile.

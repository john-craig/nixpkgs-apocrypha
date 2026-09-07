## Why

The existing NixOS OpenCode user module composes the OpenCode and agent Home
Manager modules but does not expose the repository's scheduled implementor
service through that profile. Consumers must currently compose the scheduler
separately, making the dedicated OpenCode user incomplete for unattended
OpenSpec work.

## What Changes

- Import the existing implementor scheduler Home Manager module into the
  OpenCode NixOS user's Home Manager profile.
- Preserve the scheduler's opt-in behavior and existing configuration options;
  enabling the NixOS user module alone will not schedule repository work.
- Add fixture coverage and documentation for configuring the scheduler through
  `evak.opencodeAgentsUser.homeManager`.
- Keep the existing user creation, OpenCode module composition, forced enables,
  and scheduler implementation behavior unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `opencode-agents-nixos-user`: Include the optional implementor scheduler in the
  selected user's Home Manager profile and document its configuration path.

## Impact

- Affected module: `nixos-modules/opencode-agents-user.nix`.
- Affected fixture and documentation: `tests/opencode-agents-user.nix` and
  `docs/opencode-agents.md`.
- No new package or service implementation is required; the existing
  `projectManagerAutomatedDevelopmentWorkflowsImplementorScheduler` module is
  reused.
- The scheduler remains disabled unless its existing `enable` option is set and
  still requires valid upstream and package configuration when enabled.

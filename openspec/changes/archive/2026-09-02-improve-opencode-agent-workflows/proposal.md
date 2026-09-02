## Why

The current OpenCode environments provide declarative roles, but implementation work
still requires manually selecting a generated configuration and supplying a directory
to the CLI. The default permission policy also makes ordinary development unnecessarily
interactive, while there is no dedicated architecture role for producing specifications
before implementation.

## What Changes

- Add a software architect role using the more capable `openai/gpt-5.6-sol` model.
- Define the architect as specification-focused: it may inspect projects and produce
  designs/specifications, but must not implement, commit, or deploy them.
- Change the developer environment to allow file edits and command execution by default,
  while retaining explicit denials and the existing user-facing permission mechanism.
- Add an all-in-one executable command that accepts an agent, target directory, and prompt,
  selects the corresponding generated environment, and invokes `opencode run`.
- Preserve the existing environment files and direct OpenCode invocation paths.

## Capabilities

### New Capabilities

- `software-architect-agent`: A specification and design role for producing implementation-ready designs without applying them.
- `opencode-agent-runner`: A user-facing command for running a configured agent against a specified directory and prompt.

### Modified Capabilities

- `opencode-agent-environments`: Add the architect role and revise developer permission defaults toward autonomous implementation.

## Impact

- `home-modules/opencode-agents/definitions.nix` and generated agent configuration.
- `home-modules/opencode-agents/default.nix` option and permission handling if needed.
- A new executable exposed through the Home Manager module and/or package set.
- OpenCode CLI invocation, generated environment paths, and focused evaluation tests.
- Existing consumers retain the current module entry point; developer sessions will have broader default authority, which is a deliberate behavior change.

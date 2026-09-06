## Why

Consumers currently need to declare a system user, wire that user into Home
Manager, import both OpenCode home modules, and enable their options manually.
That repeated integration is easy to misconfigure and makes the repository's
agent-enabled user experience less portable across NixOS configurations.

## What Changes

- Add a public NixOS module that declares and configures one OpenCode-enabled user.
- Require a configurable username and support the relevant NixOS user details, including home directory, UID/GID, groups, shell, description, and normal-user behavior.
- Configure the user's Home Manager entry to enable the existing `opencode` and `opencode-agents` home modules.
- Provide a supported customization point for the user's Home Manager settings, including agent configuration and OpenCode settings, without disabling the two required modules.
- Make the module's Home Manager dependency and invalid configurations fail clearly at evaluation time.
- Add module evaluation tests, a NixOS/Home Manager integration test, and consumer-facing documentation with a minimal example.

## Capabilities

### New Capabilities

- `opencode-agents-nixos-user`: Provides a configurable NixOS user whose Home Manager configuration has the repository's OpenCode and OpenCode agent modules enabled.

### Modified Capabilities

None.

## Impact

- `nixos-modules/default.nix` and a new NixOS module implementation become the public module entry point.
- Home Manager becomes an integration dependency for the module's intended use; the consumer must expose its NixOS module to the system configuration unless the implementation vendors or otherwise imports it explicitly.
- The module will compose `home-modules/opencode` and `home-modules/opencode-agents`, so the existing OpenCode package/overlay and agent definitions remain the source of truth.
- New tests and documentation will establish the option interface, generated system user, enabled Home Manager modules, customization precedence, and evaluation failures.

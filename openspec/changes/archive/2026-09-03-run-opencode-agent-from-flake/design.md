## Context

The existing Home Manager module generates one OpenCode JSON environment per agent,
stores role prompts as Nix store files, and installs a runner whose script embeds the
configured OpenCode package and resolves environments beneath `$HOME/.config/opencode`.
The flake currently exports packages through `default.nix` and `flake.nix`, but the
runner is only available after Home Manager activation.

## Goals / Non-Goals

**Goals:**

- Provide a reproducible `opencode-agent` flake package and `nix run` entry point.
- Make the standard generated environments available to that package at runtime.
- Keep the current command-line contract, validation, and permission boundaries.
- Permit an explicit environment-root override without copying user secrets into the store.
- Test direct execution with a fake OpenCode executable and inspect generated artifacts for secret leakage.

**Non-Goals:**

- Do not deploy Home Manager, alter user profiles, or mutate target repositories.
- Do not create a second agent-definition source that can diverge from the Home Manager definitions.
- Do not bundle OpenCode itself, provider credentials, MCP services, or machine-specific secrets.

## Decisions

1. **Reuse the declarative agent definitions.** Refactor or expose the existing generated
   environment construction so both the Home Manager module and the flake package use
   the same role, skill, rule, and permission data. Duplicating prompts would allow the
   direct runner and deployed runner to drift.

2. **Ship environments as package data.** The flake package will include generated
   environment JSON and prompt/skill/rule files under a stable package-local directory.
   The runner will use that directory by default and accept an explicit environment-root
   override for customized environments. Package-local paths are acceptable in generated
   configuration; credentials and host-specific paths are not.

3. **Keep approval behavior in OpenCode configuration.** The runner will only select the
   environment and invoke `opencode run`; it will not add `--auto`, widen permissions, or
   rewrite the selected configuration. This keeps direct execution behavior equivalent to
   the installed runner.

4. **Use a dedicated package entry point.** Expose `opencode-agent` through the existing
   `default.nix`, flake `legacyPackages`, and flake package outputs. Keep the Home Manager
   runner implementation compatible, using shared generation logic where practical rather
   than changing its public command contract.

5. **Make environment selection explicit and fail closed.** The default package data
   directory is used only when present; an override must resolve to an existing directory
   containing the requested generated environment. Invalid roots and agents fail before
   OpenCode is started.

## Risks / Trade-offs

- [Generated environments may duplicate package data] -> Generate both module and package outputs from one shared definition and test representative roles for equivalence.
- [A package-local prompt may reference a garbage-collected or unavailable path] -> Keep all package-owned prompt, skill, and rule files inside the same package closure and test a direct invocation with a fake OpenCode binary.
- [Users may expect direct execution to use their customized Home Manager environment] -> Document the default packaged environment and the explicit environment-root override separately.
- [MCP declarations may name unavailable runtime binaries] -> Preserve declarations only, clearly report that runtime tools and credentials remain consumer-supplied, and do not claim integrations are operational.
- [The package runner could accidentally bypass approvals] -> Assert generated permissions in the focused check and ensure the wrapper invokes only normal `opencode run` arguments.

## Migration Plan

1. Implement shared environment generation and the flake package.
2. Run the focused Nix check and direct fake-OpenCode invocation.
3. Validate `nix run .#opencode-agent -- --help` and a representative agent invocation.
4. Continue using the Home Manager module unchanged for installed environments.
5. Roll back by removing the package export; existing Home Manager-generated runners remain available.

## Context

See `proposal.md` for motivation and scope. The current repository exports a small OpenCode Home Manager module that generates JSON configuration and notifier assets. Panoply's source model is a Nix module with Codex settings, markdown instructions, reusable skills/rules/subagents, MCP attributes, authentication metadata, and project-discovery policy. `opencode-nix` supplies typed OpenCode configuration generation and package integration, but does not provide the required Panoply role inventory.

## Goals / Non-Goals

**Goals:**

- Add a repository-local, declarative OpenCode environment abstraction.
- Preserve the 15 source roles and their safety boundaries.
- Generate OpenCode configuration from typed Nix values and expose it through the dedicated agent module.
- Keep package and configuration generation reproducible through a flake input following upstream `opencode-nix`.
- Make generated output and migration coverage testable without live services.

**Non-Goals:**

- Reimplement Panoply's deployment, launcher, service, or secret-management infrastructure.
- Make unavailable MCP binaries or remote endpoints operational.
- Preserve Codex-only launcher semantics where OpenCode has no equivalent.
- Migrate secret values or automatically import user credentials.

## Decisions

### Use a Home Manager adapter, not a Panoply dependency

The new options and generators will live in a dedicated `home-modules/opencode-agents` module, with an `evak.opencode-agents` namespace. It will generate agent configuration independently from `home-modules/opencode`, allowing users to compose agent roles with the existing TUI customizations without coupling either module to Panoply.

Alternative considered: import Panoply's agent modules directly. Rejected because it retains the unwanted repository/runtime coupling and leaves Codex-specific option semantics in the OpenCode interface.

### Use `opencode-nix` as the configuration layer

Add `github:albertov/opencode-nix` as a flake input and use its typed `pkgs.lib.opencode.mkOpenCodeConfig` module composition for generated configuration. Use its overlay/package integration rather than maintaining a second local representation of OpenCode's agent, permission, MCP, and skill schema. Agent role definitions and source migration inventory remain local because they are domain-specific.

Alternative considered: use `llm-agents.nix`. Rejected because it is primarily a package collection and does not provide the typed OpenCode configuration module needed for this change.

### Represent environments as explicit named data

Use a typed `attrsOf` submodule for environments, with separate fields for prompt/instructions, skills, rules, subagents, MCP servers, model/config settings, authentication references, and isolation intent. Shared definitions may be declared once and selected explicitly by name.

Alternative considered: generate one global prompt/config assembled from all roles. Rejected because it violates environment isolation and makes role boundaries impossible to audit.

### Generate configuration declaratively and preserve secret references

Use `opencode-nix`'s typed generator for JSON and local repository files for long prompts/skills where runtime `{file:...}` references are appropriate. Authentication fields will contain paths or environment-variable references only; assertions will reject missing required references. Runtime activation may make generated files writable only where the existing module requires it, but it will not copy secret contents into the Nix store.

### Model compatibility gaps explicitly

Codex settings will be mapped only where OpenCode has an equivalent. Unsupported launcher behavior, sandbox controls, or project-home mechanics will be documented as compatibility gaps and covered by tests or migration notes rather than silently approximated.

## Risks / Trade-offs

- [OpenCode schema drift] -> Pin and update the `opencode-nix` input deliberately, rely on its typed options and schema checks, and run evaluation checks against representative environments.
- [Codex/OpenCode semantic mismatch] -> Maintain a source-to-target inventory and mark unsupported behavior explicitly instead of claiming parity.
- [MCP commands may be absent] -> Generate declarations without asserting runtime availability; test structure and secret non-leakage only.
- [Large generated configuration] -> Keep reusable definitions separate from per-environment selections and test selected output rather than duplicating content unnecessarily.
- [Existing dirty module changes] -> Preserve the current unrelated modification to `home-modules/opencode/default.nix`; add the new module under `home-modules/opencode-agents` rather than expanding that file's responsibilities.

## Migration Plan

1. Add and lock the `opencode-nix` flake input; expose its typed configuration library and OpenCode package integration for Home Manager use.
2. Implement the new typed agent options and generator behind `evak.opencode-agents.enable` in `home-modules/opencode-agents`.
3. Port all source environments and reusable definitions, recording unsupported mappings.
4. Add exports, documentation, and focused Nix evaluation checks.
5. Validate generated output and compare the migration inventory with Panoply.

Rollback consists of disabling the new environment option and removing the input/module wiring; the existing global OpenCode customization remains independently usable.

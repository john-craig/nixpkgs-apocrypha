## Context

See `proposal.md` for motivation. The flake currently exports NixOS modules and
Home Manager modules independently. The two relevant Home Manager modules use
the `evak.opencode` and `evak.opencode-agents` option namespaces, while the
agent module also expects an OpenCode package to be available through `pkgs` or
an explicit option.

## Goals / Non-Goals

**Goals:**

- Provide one declarative NixOS entry point for a user with the existing
  OpenCode experience.
- Preserve the existing home modules as the implementation source of truth.
- Keep ordinary NixOS user attributes and per-user Home Manager settings
  consumer-configurable.
- Fail early and clearly when the required Home Manager integration is absent.

**Non-Goals:**

- Reimplementing or forking either OpenCode Home Manager module.
- Managing credentials, API keys, or an OpenCode package overlay in the new
  NixOS module.
- Supporting multiple independently configured users from one module instance;
  consumers can instantiate the module multiple times only if the option design
  explicitly permits that without collisions.

## Decisions

### Expose one module instance with a structured user option

Add a module such as `nixosModules.opencodeAgentsUser` with an enable option,
`username`, a structured `user` attrset for supported `users.users.<name>`
attributes, and a `homeManager` attrset for the selected user's Home Manager
configuration. Keep `username` separate so it is unambiguous which system and
Home Manager entries are generated; merge the remaining user details into
`users.users.${username}`.

Alternative considered: accept the complete `users.users` and
`home-manager.users` trees. Rejected because it weakens validation, makes
targeting unclear, and allows the module to modify unrelated users.

### Compose existing modules through the per-user Home Manager entry

The generated `home-manager.users.${username}` definition will import
`home-modules/opencode` and `home-modules/opencode-agents`, then set both
enable options. Consumer-supplied Home Manager settings will be merged into
that entry so agent definitions, permissions, models, plugins, and ordinary
Home Manager options remain configurable.

Alternative considered: copy the home-module implementation into the NixOS
module. Rejected because it would create two sources of truth and drift from
the directly exported Home Manager modules.

### Make required enables non-overridable

Use module merge priorities so the composed imports and the two required enable
options remain active even when the customization attrset contains false
values. Other consumer options retain normal Home Manager merge behavior.

Alternative considered: document that consumers must not disable the options.
Rejected because the module's primary guarantee would then be easy to violate
silently.

### Require the consumer's Home Manager NixOS integration

Detect the presence of the Home Manager per-user option during module
evaluation and emit a targeted assertion when it is absent. The module will
not add Home Manager as a new flake input or manage the consumer's input
follows relationship; the consumer remains responsible for importing the
compatible Home Manager NixOS module.

Alternative considered: add Home Manager as a repository flake input and import
it automatically. Rejected because it would impose a dependency/version choice
on consumers and differs from the current independent module exports.

### Treat package availability as an existing integration concern

The module will not silently select or package OpenCode. Consumers will use the
same overlay or package configuration required by the existing
`opencode-agents` home module, and tests will cover a package supplied in the
evaluation fixture.

## Risks / Trade-offs

- [Home Manager option and module APIs can change] → Pin/test the integration against the repository's supported Home Manager shape and keep the composition limited to the stable `home-manager.users` interface.
- [A generic customization attrset can contain conflicting options] → Use a typed username/user surface, preserve required enables with merge priority, and test precedence explicitly.
- [The OpenCode package may be absent from `pkgs`] → Retain the existing agent module assertion and document the required overlay or explicit package option.
- [Changing the username can leave an old system user behind] → Document that renaming is a normal NixOS user migration and does not implicitly delete the previous account.
- [Multiple instances could collide if options are global] → Scope the module to one configured username and reject or document duplicate-instance behavior in tests before implementation.

## Migration Plan

1. Import the repository NixOS module, import the consumer's Home Manager NixOS module, and enable the new module with a username.
2. Move any existing per-user OpenCode and agent settings into the module's Home Manager customization attrset, removing duplicate imports and enable assignments.
3. Build the NixOS configuration and verify the generated user's Home Manager activation contains the expected OpenCode files and runner.
4. Roll back by removing the new module and restoring the previous explicit user/Home Manager declarations; no data migration is required.

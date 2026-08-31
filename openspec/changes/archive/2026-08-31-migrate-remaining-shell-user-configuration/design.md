## Context

Panoply imports its shell module family through `modules/userModules/shellModules/default.nix`. Tmux and zsh behavior has already been extracted into this repository, VSCodium is a separate Home Manager module, and OpenCode TUI customization is a separate capability. The remaining modules mix portable Home Manager configuration with Panoply-specific cluster resolution, SOPS paths, NixOS `nix.*` options, custom packages, and shell aliases/environment variables.

## Goals / Non-Goals

**Goals:**

- Produce independently consumable Home Manager modules for every remaining active shell-module concern.
- Preserve active package, file, program, activation, and CLI behavior while removing Panoply option-tree coupling.
- Keep secret values external and make topology, repository paths, and service endpoints explicit inputs.
- Avoid reintroducing shell aliases or ambient environment variables that were intentionally removed from the zsh module.
- Keep modules individually testable and exportable from `homeModules`.

**Non-Goals:**

- Re-migrating tmux, zsh, VSCodium, or OpenCode TUI customization.
- Copying commented-out aliases, plugins, hooks, or abandoned configuration experiments.
- Publishing SOPS secrets, API tokens, private keys, or token contents.
- Making a Home Manager module own NixOS-only options such as `nix.extraOptions` or system user creation.
- Reproducing Panoply's entire cluster or deployment framework inside this repository.

## Decisions

- **Group modules by behavior, not by source directory count.** Four capability specs keep the plan reviewable while tasks enumerate each source module: CLI applications, development tooling, SSH, and restricted shell.
- **Use explicit module-owned enable options.** Each migrated feature will expose a stable option under a repository-owned namespace and will gate packages/files/configuration on that option. Standard Home Manager options remain the implementation surface where they exist.
- **Do not migrate aliases or session variables.** This applies to `programs.zsh.shellAliases`, `home.sessionVariables`, PATH manipulation, and generated directory variables across the source modules. Executables remain available through `home.packages` or documented paths, not shell mutation.
- **Split portable Nix client behavior from system configuration.** Home Manager may provide the Nix client package or user-facing configuration only where supported; `nix.extraOptions`, cross-compilation platform settings, and QEMU assumptions become a documented NixOS-side follow-up rather than invalid Home Manager code.
- **Replace implicit topology with typed inputs.** SSH host/address resolution will accept an explicit map or list of host definitions and preserve identity files/options without importing Panoply cluster data. Alucard deployment helpers will accept a configurable repository path and keep logging behavior in a script/package rather than relying on a Panoply environment variable.
- **Make secret-backed activation configurable.** GitHub hosts, ChatGPT credentials, Toot credentials, Twitch environment files, and Codex authentication will use configurable secret paths or Home Manager/SOPS integration points. Activation must set restrictive permissions and fail clearly when a required secret is absent.
- **Keep agent configuration out of this change.** Codex and primary-agent launcher configuration are intentionally deferred; the existing `opencode-customizations` capability remains the owner of OpenCode TUI files, theme, notifier, and productivity plugins.
- **Use focused evaluation per capability.** Tests will inspect module exports, package sets, generated files, option values, activation script contents, and disabled behavior. Live network services, cluster hosts, desktop sessions, and authenticated APIs are out of scope.

## Risks / Trade-offs

- **Some source packages may not exist in every nixpkgs revision** -> Resolve package availability during implementation and document unavailable optional tools instead of silently substituting unrelated packages.
- **SSH configuration is tightly coupled to Panoply topology** -> Require explicit host definitions and test representative static and dynamically addressed entries.
- **Secret activation behavior can expose credentials or leave stale files** -> Use external paths, restrictive permissions, atomic temporary files where practical, and tests that assert token contents are not embedded.
- **NixOS-only settings cannot be faithfully moved to Home Manager** -> Split the contract and document the remaining system-level configuration instead of forcing unsupported options.
- **Large source modules can create broad diffs** -> Implement one capability/module at a time and keep each focused test tied to its source behavior.

## Migration Plan

1. Implement and validate each capability group independently, beginning with portable CLI tools.
2. Import the new modules in the consuming user profile and disable the corresponding Panoply shell modules to avoid duplicate definitions.
3. Supply explicit repository, cluster, and secret-path inputs during activation.
4. Compare package availability, generated files, SSH behavior, and restricted-shell behavior with Panoply.
5. Keep NixOS-only settings in the host configuration until a separate system-module change is approved.
6. Roll back any capability by removing its module import and enablement; no state migration is required except cleanup of generated secret-backed files.

## 1. Inventory And Compatibility Baseline

- [x] 1.1 Inventory every option, package, generated file, activation action, assertion, and Home Manager program setting in the three aggregate modules; verify the inventory covers all current behavior before edits.
- [x] 1.2 Record current module exports, option paths, and focused test expectations; verify a baseline `nix flake check` passes before the refactor.

## 2. CLI Tool Modules

- [x] 2.1 Create dedicated modules for `alucard`, `chatgpt-cli`, `claude-code`, `dismas`, `instagram`, `paru`, `tea`, `toot`, and `twitch` under `home-modules`, preserving `evak.shell.cli.*` options; verify each disabled module adds no outputs and each enabled module preserves its package/configuration behavior.
- [x] 2.2 Move shared CLI package and credential-activation helpers into a narrowly scoped reusable helper without changing activation ordering or file permissions; verify credential-backed checks still use external paths and user-only permissions.
- [x] 2.3 Replace `home-modules/shell-cli-tools/default.nix` with an aggregate import/composition module and preserve its public `homeModules.shellCliTools` export; verify existing aggregate consumers evaluate unchanged.

## 3. Development Tool Modules

- [x] 3.1 Create dedicated modules for Git, GitHub CLI, direnv, and portable Nix under `home-modules`, preserving `evak.shell.development.*` options and package defaults; verify each feature remains independently enableable.
- [x] 3.2 Preserve Git identity/signing/default-branch behavior, GitHub hosts-file activation, direnv/nix-direnv integration, and portable Nix configuration while splitting implementations; verify focused evaluations cover each behavior and unsupported NixOS options remain absent.
- [x] 3.3 Replace `home-modules/shell-development-tools/default.nix` with an aggregate import/composition module and preserve its public `homeModules.shellDevelopmentTools` export; verify existing aggregate consumers evaluate unchanged.

## 4. SSH Tool Modules

- [x] 4.1 Split SSH client configuration, SSH agent setup, host topology validation, and specialized helper-package handling into dedicated modules under `home-modules`; verify the chosen module boundaries preserve all current `evak.shell.ssh.*` options.
- [x] 4.2 Preserve enabled-host address validation, match-block generation, identity-file handling, agent package selection, and helper-package gating; verify static, dynamic, unresolved-host, and secret-boundary checks without contacting remote hosts.
- [x] 4.3 Replace `home-modules/shell-ssh/default.nix` with an aggregate import/composition module and preserve its public `homeModules.shellSsh` export; verify aggregate imports retain current behavior.

## 5. Exports Documentation And Tests

- [x] 5.1 Update `home-modules/default.nix` with granular per-tool exports while retaining aggregate exports; verify every documented module path resolves.
- [x] 5.2 Update README/docs and the three OpenSpec capability references to describe the per-tool directory layout, compatibility aggregates, option paths, and migration behavior; verify documentation matches the exported files.
- [x] 5.3 Expand or split focused evaluation tests to cover every child module, aggregate composition, disabled behavior, package assertions, secret activation, SSH validation, and no-shell-mutation guarantees; verify all new checks pass.
- [x] 5.4 Run formatter, targeted checks, full `nix flake check`, and `git diff --check`; inspect the final diff for preserved public options and absence of unrelated changes.

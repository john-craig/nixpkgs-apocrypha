# Shell User Configuration

The migrated features are independent Home Manager modules. Import only the
capabilities needed by a profile:

```nix
imports = [
  inputs.nixpkgs-apocrypha.homeModules.shellCliTools
  inputs.nixpkgs-apocrypha.homeModules.shellDevelopmentTools
  inputs.nixpkgs-apocrypha.homeModules.shellSsh
  inputs.nixpkgs-apocrypha.homeModules.restrictedShell
];

evak.shell.cli.tea.enable = true;
evak.shell.development.git.enable = true;
evak.shell.ssh = {
  enable = true;
  hosts.builder = { hostname = "builder.example"; user = "evak"; };
};
```

Per-tool exports (`homeModules.tea`, `homeModules.git`, `homeModules.ssh`, and
`homeModules.lshell`) point to the same focused capability modules. Every
package option is typed as `nullOr package`; if a package is absent from the
pinned nixpkgs, enablement asserts with an override hint instead of breaking
module import.

Credential paths for ChatGPT, Toot, Twitch, and GitHub are external files and
are copied with mode `0600` during activation. No credential contents, aliases,
or ambient session variables are defined here. Alucard's repository path and
SSH topology are explicit inputs. Specialized SSH helper packages are supplied
through `evak.shell.ssh.helperPackages` only when needed.

The portable Nix module provides the client package and optional user
`nix.conf`. NixOS daemon, cross-compilation, QEMU, and system-user settings
remain host configuration and are intentionally not set by Home Manager.

## Migration Matrix

| Source concern | Module | Main options | External inputs |
| --- | --- | --- | --- |
| Alucard, ChatGPT, Claude Code, Dismas, Instagram, Paru, Tea, Toot, Twitch | `shellCliTools` | `evak.shell.cli.*` | package overrides, credential paths, Alucard repository |
| Git and pre-commit | `shellDevelopmentTools` | `evak.shell.development.git` | identity and optional signing key |
| GitHub CLI | `shellDevelopmentTools` | `evak.shell.development.github` | external `hosts.yml` |
| direnv and nix-direnv | `shellDevelopmentTools` | `evak.shell.development.direnv` | none |
| Portable Nix client | `shellDevelopmentTools` | `evak.shell.development.nix` | optional user config |
| SSH agent and topology | `shellSsh` | `evak.shell.ssh` | explicit host map, identity paths, helper packages |
| lshell | `restrictedShell` | `evak.shell.restricted` | existing/overridden `lshell` package |

The primary-agent launcher and Codex configuration are deliberately outside
this change; OpenCode TUI customization remains in `homeModules.opencode`.

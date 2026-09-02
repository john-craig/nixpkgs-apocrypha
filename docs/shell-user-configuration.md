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

Per-tool exports (`homeModules.alucard`, `homeModules.chatgptCli`,
`homeModules.claudeCode`, `homeModules.dismas`, `homeModules.instagram`,
`homeModules.paru`, `homeModules.tea`, `homeModules.toot`, `homeModules.twitch`,
`homeModules.git`, `homeModules.github`, `homeModules.direnv`,
`homeModules.nix`, `homeModules.sshClient`, `homeModules.sshAgent`,
`homeModules.sshHosts`, `homeModules.sshHelpers`, and `homeModules.lshell`) point
to focused capability modules. The aggregate exports remain available for
profiles that prefer one import per capability. Every
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

The CLI child modules are `alucard`, `chatgpt-cli`, `claude-code`, `dismas`,
`instagram`, `paru`, `tea`, `toot`, and `twitch`; each installs its matching
package when `evak.shell.cli.<name>.enable` is true. Alucard additionally
generates `~/.config/alucard/hosts.nix` and reads completions from its
configured repository. ChatGPT, Toot, and Twitch copy configured external
credential files during activation. The Git, GitHub, direnv, and Nix child
modules similarly map to `evak.shell.development.git`,
`evak.shell.development.github`, `evak.shell.development.direnv`, and
`evak.shell.development.nix`; `shellDevelopmentTools` remains the compatible
aggregate. SSH can be imported as `sshClient`, `sshAgent`, `sshHosts`, or
`sshHelpers`, while `shellSsh` imports all four and retains the complete
`evak.shell.ssh` option set.

## Migration Matrix

| Source concern | Module | Main options | External inputs |
| --- | --- | --- | --- |
| Alucard, ChatGPT, Claude Code, Dismas, Instagram, Paru, Tea, Toot, Twitch | `shellCliTools` or the matching per-tool export | `evak.shell.cli.*` | package overrides, credential paths, Alucard repository |
| Git and pre-commit | `shellDevelopmentTools` or `git` | `evak.shell.development.git` | identity and optional signing key |
| GitHub CLI | `shellDevelopmentTools` or `github` | `evak.shell.development.github` | external `hosts.yml` |
| direnv and nix-direnv | `shellDevelopmentTools` or `direnv` | `evak.shell.development.direnv` | none |
| Portable Nix client | `shellDevelopmentTools` or `nix` | `evak.shell.development.nix` | optional user config |
| SSH client, agent, hosts, and helpers | `shellSsh` or `sshClient`, `sshAgent`, `sshHosts`, `sshHelpers` | `evak.shell.ssh` | explicit host map, identity paths, helper packages |
| lshell | `restrictedShell` | `evak.shell.restricted` | existing/overridden `lshell` package |

The primary-agent launcher and Codex configuration are deliberately outside
this change; OpenCode TUI customization remains in `homeModules.opencode`.

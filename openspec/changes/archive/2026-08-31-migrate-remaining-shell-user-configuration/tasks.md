## 1. Core CLI Tools

- [x] 1.1 Add standalone modules for Alucard and Dismas; verify packages, config files, deployment/helper behavior, and no shell aliases or ambient variables
- [x] 1.2 Add standalone modules for ChatGPT CLI and Claude Code; verify package and credential-path behavior without embedding API keys
- [x] 1.3 Add standalone modules for Instagram CLI and Paru; verify package overrides and no shell aliases
- [x] 1.4 Add standalone modules for Tea, Toot, and Twitch CLI; verify activation-generated credential files use restrictive permissions and external secrets
- [x] 1.5 Add CLI capability evaluation coverage and per-feature documentation; verify enabled/disabled behavior for every source module

## 2. Development Tools

- [x] 2.1 Add Git module with pre-commit dependency, identity/signing settings, and explicit configurable personal values; verify no secrets or aliases are introduced
- [x] 2.2 Add GitHub CLI module with configurable secret-backed hosts activation; verify permissions and missing-secret behavior
- [x] 2.3 Add direnv/nix-direnv module and verify zsh integration through standard Home Manager options
- [x] 2.4 Split portable Nix client settings from NixOS-only options and document the system-level follow-up; verify Home Manager evaluation excludes unsupported options
- [x] 2.5 Add development-tool evaluation coverage, exports, and documentation

## 3. SSH and Restricted Shell

- [x] 3.1 Add typed explicit SSH host/address options, agent configuration, and static match blocks; verify representative generated configurations
- [x] 3.2 Port dynamic cluster host resolution and specialized TOTP/honeypot entries behind explicit inputs; verify unresolved hosts fail clearly and helper packages are gated
- [x] 3.3 Add the lshell Home Manager module using the existing package and configurable allowlists; verify safe quoting and disabled behavior
- [x] 3.4 Add SSH/restricted-shell tests, exports, and documentation without creating system users or copying private keys

## 4. Integration and Verification

- [x] 4.1 Export all migrated modules from `home-modules/default.nix` and the flake `homeModules` output; verify every public module resolves
- [x] 4.2 Add a migration matrix documenting each Panoply source module, target module, options, dependencies, secrets, and deliberate exclusions
- [x] 4.3 Run focused evaluations, `nix flake check path:$PWD`, and strict OpenSpec validation; verify no existing tmux, zsh, VSCodium, or OpenCode customization behavior regresses

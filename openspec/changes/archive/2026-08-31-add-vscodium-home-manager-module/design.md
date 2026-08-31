## Context

Panoply's `modules/userModules/applicationModules/vscodium/default.nix` is gated by `userServices.applicationServices.vscodium`. It builds the SynthWave '84 marketplace extension, appends its CSS to the VSCodium workbench stylesheet through an overridden package, and configures the default VS Code profile with settings, keybindings, and extensions. The source currently sets both `profiles.default` and `mutableExtensionsDir = true`, which current Home Manager documentation identifies as mutually exclusive.

## Goals / Non-Goals

**Goals:**

- Expose the complete active VSCodium configuration as a standalone Home Manager module.
- Preserve the editor theme, CSS patch, extensions, keybindings, font, terminal integration, and user settings.
- Keep activation explicit and independent of Panoply's application-service hierarchy.
- Use a declarative profile consistent with current Home Manager constraints.
- Verify the module export and resolved profile through focused Nix evaluation.

**Non-Goals:**

- Changing Panoply's existing VSCodium module or desktop application wiring.
- Preserving commented-out extensions or obsolete nixpkgs override experiments.
- Supporting mutable, manually managed extensions in the declarative profile.
- Adding a new custom settings schema when Home Manager already exposes the required VS Code profile options.

## Decisions

- **Expose `homeModules.vscodium` and use `programs.vscode.enable`.** The Home Manager option namespace is named `programs.vscode` even when the selected package is VSCodium. Reusing that interface avoids a second enable flag and matches the existing tmux and zsh modules.
- **Select VSCodium through `programs.vscode.package`.** The module will override the nixpkgs VSCodium derivation to append the generated SynthWave CSS patch. This keeps the patched executable and declarative profile under one module.
- **Build the SynthWave extension from the marketplace reference.** Preserve the source publisher, name, version, and fixed hash, then read its supplied CSS into the package post-install patch. This reproduces the active source behavior rather than inventing a separate theme asset.
- **Use `profiles.default` and omit `mutableExtensionsDir`.** The profile is required for settings, keybindings, and extensions, while Home Manager marks it mutually exclusive with mutable extension management. Declarative extension state takes precedence; consumers needing manual extensions remain outside this module's contract.
- **Preserve the tmux terminal profile exactly.** The default Linux terminal profile will invoke `zsh -c tmux`, with chord handling disabled and tmux selected as the default. The module will not implicitly import or enable the separate tmux or zsh modules.
- **Keep active extensions only.** Include Jinja, Python, GitHub Copilot, Nix IDE, and SynthWave '84. The commented Wakatime and Copilot Chat entries are not active configuration and will not be ported.

## Risks / Trade-offs

- **VSCodium package patching may break when its resource path changes** -> Build the patched derivation against pinned nixpkgs and verify the expected CSS path during evaluation/build.
- **Marketplace extension availability or hashes may change** -> Preserve fixed metadata and let Nix's hash verification fail clearly if upstream content changes.
- **Removing mutable extension management changes manual extension behavior** -> Document the declarative-only contract and require consumers to add extensions through the profile.
- **tmux and zsh may not be installed by this module** -> Document those runtime assumptions and keep their configuration in their dedicated modules.
- **Home Manager profile option semantics may evolve** -> Validate against the repository's pinned nixpkgs and assert the mutually exclusive option is not set.

## Migration Plan

1. Add the module, exports, focused evaluation, and documentation.
2. Import `homeModules.vscodium` in the consuming Home Manager profile and set `programs.vscode.enable = true`.
3. Confirm VSCodium launches with the SynthWave theme, patched neon CSS, configured extensions, keybindings, and tmux terminal.
4. Remove the old Panoply module import or disable its VSCodium service to avoid duplicate definitions.
5. Roll back by removing the module import; no state migration is required.

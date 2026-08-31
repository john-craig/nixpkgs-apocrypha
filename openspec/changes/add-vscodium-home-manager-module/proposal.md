## Why

The VSCodium configuration for user `evak` currently lives in Panoply's private application-module tree, so it cannot be reused by Home Manager configurations consuming this NUR repository. Moving the configuration into a published module will make the editor package, SynthWave '84 customization, extensions, settings, and terminal integration reproducible from one source.

## What Changes

- Add a reusable `homeModules.vscodium` Home Manager module based on Panoply's VSCodium configuration.
- Activate the module through Home Manager's standard `programs.vscode.enable` option and configure the VSCodium package.
- Preserve the SynthWave '84 marketplace extension and patched VSCodium workbench CSS.
- Preserve the configured editor settings, tmux terminal profile, and custom keybindings.
- Preserve the declaratively installed Jinja, Python, GitHub Copilot, Nix IDE, and SynthWave '84 extensions.
- Resolve the Home Manager incompatibility between `profiles` and `mutableExtensionsDir` by using the declarative profile and omitting or disabling mutable extension management.
- Export the module from both the NUR attribute set and the flake's `homeModules` output.
- Add focused evaluation coverage and usage documentation.

## Capabilities

### New Capabilities

- `vscodium-home-manager`: Reusable declarative VSCodium configuration for Home Manager.

### Modified Capabilities

## Impact

- New VSCodium module and CSS-patching package expression under `home-modules/`.
- `default.nix` and `flake.nix` Home Manager exports.
- Home Manager's `programs.vscode` package, profile, extension, settings, and keybinding options.
- VSCodium and marketplace extension downloads during evaluation/build.
- README documentation and focused Nix evaluation tests.

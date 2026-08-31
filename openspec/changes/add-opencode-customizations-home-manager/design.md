## Context

Panoply's `modules/userModules/shellModules/primaryAgent/default.nix` currently combines OpenCode runtime configuration with the TUI customization. It generates `tui.json`, a semantic SynthWave theme, `opencode-notifier.json`, and a Gotify/Hyprland command; the consuming evak profile adds three plugin identifiers. Panoply's flake check already validates the generated JSON. The completion sound is currently shared from the Codex module at `modules/userModules/shellModules/codex/ding.mp3`.

## Goals / Non-Goals

**Goals:**

- Provide a standalone `homeModules.opencode` module for the documented TUI customizations.
- Preserve the exact active theme semantics, plugin versions, notifier threshold, sound behavior, and notification fallback.
- Keep secrets external and notification delivery best-effort.
- Make the module usable without Panoply's primary-agent, Codex, MCP, or shell module trees.
- Verify generated files and public exports through focused Nix evaluation.

**Non-Goals:**

- Reproducing OpenCode model, permission, MCP, instruction, or launcher-wrapper configuration.
- Adding or modifying zsh aliases, environment variables, or the primary `agent` command.
- Replacing the upstream OpenCode notifier, quota, or quotes plugins with local implementations.
- Requiring a running OpenCode, Wayland, Hyprland, Gotify, or audio session during evaluation.

## Decisions

- **Use an explicit `evak.opencode.enable` option.** Home Manager has no standard OpenCode module option, so the module needs an owned activation switch. This avoids overloading unrelated `programs.*` namespaces and avoids enabling files merely because the module is imported.
- **Generate OpenCode configuration with `pkgs.formats.json`.** `tui.json`, `opencode-notifier.json`, and the plugin-bearing OpenCode configuration will be generated declaratively, preserving valid JSON and allowing focused assertions. The module will keep runtime OpenCode settings outside this change.
- **Install the theme under the configured theme name.** The default will remain `synthwave-84`, with semantic roles mapped from the VSCodium SynthWave palette. A configurable theme name will keep the file path and `tui.json` selection consistent.
- **Keep plugin identifiers in OpenCode configuration.** The notifier, quota, and quotes entries will use the exact active versions/paths from Panoply. Nix will manage the configuration, while OpenCode remains responsible for fetching and loading those plugins.
- **Generate the notifier command with Nix-provided values.** Gotify URL, token path, priority, and fallback behavior will be configurable. The token will remain an external runtime file; the command will attempt Gotify first, fall back to `hyprctl notify`, and suppress delivery failures.
- **Copy the existing completion sound into the module.** The source `ding.mp3` will be included as a managed module asset rather than reaching into Panoply or the Codex module. This makes the module self-contained without duplicating runtime behavior.
- **Preserve declarative file locations.** The module will install `~/.config/opencode/tui.json`, `~/.config/opencode/themes/<theme>.json`, and `~/.config/opencode/opencode-notifier.json`, matching the documented OpenCode global locations.

## Risks / Trade-offs

- **OpenCode plugin configuration or schema may change** -> Pin plugin identifiers, validate generated JSON, and document the OpenCode version/runtime check.
- **Theme keys may not match future OpenCode releases** -> Keep the semantic theme explicit and validate its generated structure against the current pinned behavior.
- **Gotify tokens and desktop commands vary by host** -> Make endpoint, token path, priority, and fallback configurable; never store token contents and keep failures non-fatal.
- **Audio utilities differ across Linux sessions** -> Preserve notifier sound configuration and document that the plugin selects an available audio utility at runtime.
- **Bundling a binary sound asset increases repository size** -> Reuse the existing small asset once in the standalone module and avoid generating additional copies.

## Migration Plan

1. Add the module, self-contained sound asset, exports, generated-file tests, and documentation.
2. Import `homeModules.opencode` and set `evak.opencode.enable = true` in the consuming Home Manager profile.
3. Configure the Gotify token path and endpoint for the target user, then activate Home Manager.
4. Restart OpenCode and verify the theme, plugins, long-turn sound, Gotify notification, and Hyprland fallback.
5. Remove the equivalent Panoply primary-agent customization or disable one source to avoid duplicate file definitions.
6. Roll back by removing the module import and enablement; no state migration is required.

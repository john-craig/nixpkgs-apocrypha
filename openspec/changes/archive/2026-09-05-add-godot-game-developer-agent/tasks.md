## 1. Agent Definition and Skills

- [x] 1.1 Add the named `godot-game-developer` environment in `home-modules/opencode-agents/definitions.nix` with Godot project inspection, implementation, debugging, testing, profiling, and export guidance; verify the generated role has the expected model, description, prompt, and project-edit permissions.
- [x] 1.2 Add a focused `godot-development` skill with routes for 2D, 3D, scene architecture, GDScript, gameplay, UI, input, animation, physics, audio, levels, resources, assets, shaders, navigation, performance, and project settings; verify relevant skill content materializes without loading an entire third-party catalog.
- [x] 1.3 Adapt patterns from GodotPrompter, GD-Agentic-Skills, and awesome-gamedev-agent-skills while preserving MIT/LGPL/Apache notices and avoiding unreviewed prompts, corpora, scripts, or assets; verify license and provenance review is documented.
- [x] 1.4 Add project-version detection, project-root isolation, untrusted-content handling, asset provenance, and explicit approval rules for live editor, arbitrary code, runtime input, export, device, network, and destructive operations; verify generated role-local guidance contains each boundary.

## 2. Godot MCP Integration

- [x] 2.1 Declare the local `godot` MCP using the reviewed `NPGameDev/godot-mcp-server` stdio command and document the required Godot addon, authenticated localhost bridge, Node.js 22+, and Godot 4.2+ prerequisites; verify no credentials or machine-specific paths enter generated configuration.
- [x] 2.2 Configure MCP safety controls, project path boundaries, response limits, audit behavior, and read-only/degraded behavior where supported; verify unavailable or disconnected MCP state is reported as non-operational.
- [x] 2.3 Keep high-risk MCP tools approval-gated, including editor mutation, arbitrary script execution, input injection, external process/network/device access, exports, and destructive asset operations; verify the permission and prompt policies agree.

## 3. Generated Configuration and Runtime Tests

- [x] 3.1 Extend `tests/opencode-agents.nix` to verify `godot-game-developer` generation, prompt and skill materialization, model, permissions, MCP declaration, isolation, and secret/path non-leakage.
- [x] 3.2 Add checks covering 2D and 3D skill routes, scene/resource/script workflows, version assumptions, asset provenance, untrusted project content, and high-risk operation approval; verify the focused OpenCode-agent test passes.
- [x] 3.3 Add bounded validation fixtures for headless Godot tests, scene-tree inspection, logs, screenshots, deterministic playtests, performance sampling, and unavailable runtime prerequisites; verify claims require observable evidence.
- [x] 3.4 Extend runner coverage to verify the new agent name, target directory, prompt preservation, and absence of implicit `--auto`; verify existing runner behavior remains unchanged.

## 4. Flake and Documentation

- [x] 4.1 Add `godot-game-developer` to the explicit generated-agent inventory in `flake.nix`; verify the flake check finds its environment JSON and prompt files.
- [x] 4.2 Document Godot version compatibility, addon/server installation, stdio/localhost transport, project-root requirements, path boundaries, and the distinction between project-file editing and live-editor/runtime control in `docs/opencode-agents.md`; verify documentation does not claim unsupported capabilities.
- [x] 4.3 Document 2D/3D workflows, asset licensing, headless validation, export/device/network restrictions, and future alternatives such as gda or Godot Sight; verify the role inventory and generated paths match configuration.

## 5. Verification

- [x] 5.1 Run formatting, focused Nix/OpenCode-agent checks, and full flake evaluation; verify all existing checks continue to pass.
- [x] 5.2 Inspect generated JSON, generated skill text, MCP configuration, and the final diff for broad permissions, remote exposure, credentials, unbounded code execution, incompatible assets, or changes outside the approved scope; verify the implementation handoff is complete.

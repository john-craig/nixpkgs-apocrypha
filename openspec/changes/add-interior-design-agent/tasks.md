## 1. Agent Definition

- [ ] 1.1 Add the named `interior-design-assistant` environment in `home-modules/opencode-agents/definitions.nix` with staged intake, survey, strategy, layout, critique, and reporting guidance; verify the generated role has the expected name, model, prompt, and conservative permissions.
- [ ] 1.2 Add a reusable `interior-design` skill covering canonical room models, furniture dimensions, circulation, openings, units, observed/inferred/proposed geometry, privacy, and professional-boundary rules; verify the role-local skill materializes with these constraints.
- [ ] 1.3 Add optional feng-shui guidance with explicit traditional/cultural framing and precedence for accessibility, safety, building code, budget, and user preferences; verify no scientific or causal claims are presented as established facts.
- [ ] 1.4 Declare the `librecad` MCP using the reviewed `thebossnow/aiblueprint-mcp` stdio integration and consumer-supplied workspace/runtime prerequisites; verify the declaration contains no machine-specific credential or path content and fails closed when unavailable.
- [ ] 1.5 Keep CAD mutation, saving, overwriting, export, conversion, print, layer/unit/metadata changes, and external operations approval-gated; verify source drawings are preserved and generated output uses a separate workspace.

## 2. Generated Configuration Tests

- [ ] 2.1 Extend `tests/opencode-agents.nix` to materialize `interior-design-assistant` and verify its prompt, `interior-design` skill, model, permissions, and `librecad` MCP declaration.
- [ ] 2.2 Add assertions for MCP isolation, no secret or home-directory leakage, unavailable integration behavior, and denied or approval-gated CAD mutations; verify unrelated environments do not inherit LibreCAD.
- [ ] 2.3 Add prompt/skill checks for inferred dimensions, unit ambiguity, collision and clearance review, professional referral boundaries, privacy handling, untrusted imported content, and feng-shui precedence.
- [ ] 2.4 Extend runner coverage to verify the role name, target directory, prompt preservation, and absence of implicit `--auto` behavior; verify existing agent runner tests continue to pass.

## 3. Flake and Documentation

- [ ] 3.1 Add `interior-design-assistant` to the explicit generated-agent inventory in `flake.nix`; verify the flake check finds its environment JSON and prompt files.
- [ ] 3.2 Document invocation, LibreCAD/aiblueprint-mcp installation options, LibreCAD 2.2.1+ and headless-preview prerequisites, isolated workspace setup, and the distinction between DXF preview automation and live LibreCAD GUI control; verify documentation does not claim unsupported runtime capabilities.
- [ ] 3.3 Document CAD approval gates, source-copy policy, geometry limitations, privacy warnings, professional-review boundaries, and feng-shui cultural framing in `docs/opencode-agents.md`; verify the role inventory and generated paths match the configuration.

## 4. Licensing and Verification

- [ ] 4.1 Review and preserve attribution for any reused MIT material from Roomsmith or aiblueprint-mcp; keep GPL-3.0 Feng-Shui-simulator, GPLv2 LibreCAD, GPLv2 Sweet Home 3D, LGPL/GPL IfcOpenShell components, and third-party furniture assets isolated or not copied unless compatible notices and source obligations are handled; verify no incompatible code or assets are embedded accidentally.
- [ ] 4.2 Run formatting, focused Nix/OpenCode-agent checks, and full flake evaluation; verify all existing checks continue to pass.
- [ ] 4.3 Inspect generated JSON, generated skill text, and the final diff for destructive permissions, credential leakage, personal-image persistence, unsupported compliance claims, or changes outside the approved scope; verify the implementation handoff is complete.

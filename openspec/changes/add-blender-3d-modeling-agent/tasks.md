## 1. Agent Definition and Skills

- [ ] 1.1 Add the named `blender-3d-modeler` environment in `home-modules/opencode-agents/definitions.nix` with Blender scene inspection, modeling, materials, animation, rendering, export, and validation guidance; verify the generated role has the expected model, prompt, and conservative permissions.
- [ ] 1.2 Add a focused `blender-modeling` skill covering mesh modeling, modifiers, geometry nodes, materials/shaders, UVs, rigging, animation, cameras, lighting, rendering, export formats, asset provenance, and mechanical/visual validation; verify the role-local skill materializes with each route.
- [ ] 1.3 Adapt typed-tool, reproducible-script, manifest, snapshot, dry-run, and validation patterns from the researched Blender repositories without copying unreviewed prompts, corpora, detector logic, or assets; verify license and attribution requirements are documented.
- [ ] 1.4 Add project-root isolation, untrusted-content handling, version assumptions, resource limits, and explicit approval rules for arbitrary Python, destructive edits, saves, renders, exports, downloads, network access, and publishing; verify generated role guidance contains each boundary.

## 2. Blender MCP Integration

- [ ] 2.1 Declare a local `blender` MCP using the reviewed `ahujasid/blender-mcp` stdio command and localhost add-on bridge; document Blender 3.0+, Python 3.10+, `uv`, add-on, workspace, safe-mode, and telemetry prerequisites; verify generated configuration contains no credentials or machine-specific paths.
- [ ] 2.2 Configure localhost binding, safe mode, telemetry policy, project/workspace boundaries, response limits, and unavailable-integration behavior; verify the role never claims the MCP is operational without observed evidence.
- [ ] 2.3 Keep arbitrary Blender Python, deletion, overwrite, modifier application, baking, expensive render/simulation, export, asset download, network, device, and external-write operations denied or approval-gated; verify the permission and prompt policies agree.

## 3. Generated Configuration and Validation Tests

- [ ] 3.1 Extend `tests/opencode-agents.nix` to verify `blender-3d-modeler` generation, prompt and skill materialization, model, permissions, MCP declaration, isolation, and secret/path non-leakage.
- [ ] 3.2 Add checks for scene planning, reproducible operations, asset manifests, snapshots, dry runs, mechanical validation, visual validation, version assumptions, and incomplete MCP evidence; verify the focused OpenCode-agent test passes.
- [ ] 3.3 Add runner coverage to verify the agent name, target directory, prompt preservation, and absence of implicit `--auto`; verify existing runner behavior remains unchanged.
- [ ] 3.4 Add bounded test fixtures for safe inspection, approved local mutation, arbitrary-code approval, destructive-operation approval, expensive render confirmation, export handling, and unavailable Blender prerequisites.

## 4. Flake and Documentation

- [ ] 4.1 Add `blender-3d-modeler` to the explicit generated-agent inventory in `flake.nix`; verify the flake check finds its environment JSON and prompt files.
- [ ] 4.2 Document Blender/MCP installation, `uvx blender-mcp`, add-on bridge, safe mode, telemetry opt-out, localhost-only requirements, project workspace boundaries, and supported version assumptions in `docs/opencode-agents.md`; verify documentation does not claim unsupported runtime behavior.
- [ ] 4.3 Document approval gates, source snapshots, asset provenance, mechanical versus visual validation, resource limits, export/publishing restrictions, and future alternatives such as blend-ai or blender-ai-mcp; verify role inventory and generated paths match configuration.

## 5. Verification

- [ ] 5.1 Run formatting, focused Nix/OpenCode-agent checks, and full flake evaluation; verify all existing checks continue to pass.
- [ ] 5.2 Review third-party licenses and notices for `ahujasid/blender-mcp`, Blender, imported assets, providers, and any reused skill material; verify no incompatible code, corpus, credentials, or assets are embedded.
- [ ] 5.3 Inspect generated JSON, generated skill text, MCP configuration, and final diff for remote exposure, broad destructive permissions, arbitrary-code bypasses, telemetry surprises, or changes outside the approved scope; verify the implementation handoff is complete.

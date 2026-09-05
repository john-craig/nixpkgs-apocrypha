## 1. Agent Definition

- [ ] 1.1 Add the shared `video-editing` skill with staged production, HyperFrames/OpenMontage routing, source-preservation, approval, preview, QC, and evidence-reporting guidance; verify the generated skill text contains each required safety gate
- [ ] 1.2 Add the `video-editing-assistant` role using the specialist model, conservative inspection permissions, selected shared skills and rules, and an explicit non-recursive workflow; verify its generated JSON contains the expected role and permissions
- [ ] 1.3 Declare the D-Ogi `mcp-kdenlive` stdio server with its documented command and arguments; verify the generated environment contains the declaration without credentials or unrelated MCP servers

## 2. Configuration and Documentation

- [ ] 2.1 Determine and implement the consumer-facing Kdenlive command/root configuration needed by the selected server without embedding machine-specific paths; verify evaluation succeeds with the documented configuration
- [ ] 2.2 Document the new agent, HyperFrames and OpenMontage upstream references, D-Ogi prerequisites, setup command, project-context expectations, approval boundaries, and unavailable-runtime behavior; verify all documented names and paths match generated files
- [ ] 2.3 Document upstream licensing and provenance policy, including the decision not to vendor OpenMontage's AGPL skill corpus; verify the documentation links resolve to the canonical repositories

## 3. Focused Verification

- [ ] 3.1 Extend `tests/opencode-agents.nix` to verify enabled and disabled materialization, prompt and skill content, role permissions, MCP isolation, and no secret or machine-specific path leakage; verify `nix build .#checks.x86_64-linux.opencode-agents` passes
- [ ] 3.2 Verify existing generated environments do not inherit Kdenlive MCP content and the new environment does not inherit unrelated servers such as Jellyfin, SSH, or TouchDesigner; verify the generated JSON assertions pass
- [ ] 3.3 Verify the existing `opencode-agent` runner can resolve and launch `video-editing-assistant` without adding implicit permissions or `--auto`; verify the fake OpenCode runner receives the selected agent and prompt unchanged
- [ ] 3.4 Run formatting and the complete flake check suite; verify `nix flake check` passes without modifying unrelated worktree files

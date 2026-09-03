# OpenCode Agent Environments

Import `homeModules.opencode-agents` and apply the repository overlay:

```nix
{
  nixpkgs.overlays = [ inputs.nixpkgs-apocrypha.overlays.opencode-nix ];
  imports = [ inputs.nixpkgs-apocrypha.homeModules.opencode-agents ];
  evak.opencode-agents.enable = true;
}
```

The module generates `.config/opencode/environments/<name>.json`, role-local
`prompt.md`, `skills/<name>/SKILL.md`, and `rules/<name>.md`. The default role is
also written to `.config/opencode/opencode-agents.json`; select another role by
setting `defaultAgent` or invoking OpenCode with
`OPENCODE_CONFIG=$HOME/.config/opencode/environments/<name>.json opencode`.

The migrated roles are `default`, `developer`, `software-architect`, `orchestrator`,
`audiovisual-design-assistant`, `disk-jockey`, `librarian`, `market-researcher`,
`note-taker`, `project-manager`, `remote-systems-diagnostics-assistant`,
`researcher`, `retrospective`, `systems-architect`, `toolsmith`,
`voice-assistant`, and `deployment-specialist`. Shared skills and rules are
selected explicitly per role.

| Panoply source environment | OpenCode environment |
| --- | --- |
| `default` | `environments/default.json` |
| `developer` | `environments/developer.json` |
| `software-architect` | `environments/software-architect.json` |
| `orchestrator` | `environments/orchestrator.json` |
| `audiovisual-design-assistant` | `environments/audiovisual-design-assistant.json` |
| `disk-jockey` | `environments/disk-jockey.json` |
| `librarian` | `environments/librarian.json` |
| `market-researcher` | `environments/market-researcher.json` |
| `note-taker` | `environments/note-taker.json` |
| `project-manager` | `environments/project-manager.json` |
| `remote-systems-diagnostics-assistant` | `environments/remote-systems-diagnostics-assistant.json` |
| `researcher` | `environments/researcher.json` |
| `retrospective` | `environments/retrospective.json` |
| `systems-architect` | `environments/systems-architect.json` |
| `toolsmith` | `environments/toolsmith.json` |
| `voice-assistant` | `environments/voice-assistant.json` |
| `deployment-specialist` | `environments/deployment-specialist.json` |

Codex launcher homes, `model_reasoning_effort`, session lifecycle behavior, and
project-home isolation have no direct OpenCode equivalent. Model names are
mapped to OpenCode provider/model identifiers; unsupported Codex settings are
not emitted. MCP entries are declarations only. Runtime binaries, endpoints,
and credentials must be supplied by the consumer. Secrets use `{env:VAR}` or
external file references and are never copied into the Nix store.

`homeModules.opencode` remains independent and can be imported alongside this
module. Run `nix build .#checks.x86_64-linux.opencode-agents` for the focused
evaluation check.

The `developer` environment allows normal file edits and command execution by
default for autonomous implementation. Override its permissions when importing
the module if a narrower policy is required:

```nix
{
  evak.opencode-agents.agents.developer.permission = {
    "*" = "deny";
    read = "allow";
    list = "allow";
  };
}
```

When the module is enabled, it also installs an `opencode-agent` command that
selects a generated environment and runs OpenCode against a target directory:

```console
opencode-agent \
  --agent developer \
  --directory /path/to/repository \
  --prompt 'Implement the requested change and run the relevant tests.'
```

The command validates the agent, directory, and prompt before starting OpenCode.
It does not implicitly pass `--auto`; the selected agent's configured permission
and approval behavior remains in effect. OpenCode and provider authentication are
runtime prerequisites and can be overridden with
`evak.opencode-agents.opencodePackage`.

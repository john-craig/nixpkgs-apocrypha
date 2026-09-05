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
`godot-game-developer`,
`podcast-writer`, `research-source-collector`,
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
| `godot-game-developer` | `environments/godot-game-developer.json` |
| `podcast-writer` | `environments/podcast-writer.json` |
| `research-source-collector` | `environments/research-source-collector.json` |

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

The same runner is available directly from this flake, without Home Manager
activation. It packages all generated agent environments and uses them by default:

```console
nix run github:john-craig/nixpkgs-apocrypha#opencode-agent -- \
  --agent systems-architect \
  --directory /path/to/repository \
  --prompt 'Produce an implementation-ready design.'
```

Use `--environment-root PATH` or `OPENCODE_AGENT_ENVIRONMENT_ROOT` to select a
separately generated environment set. The runner still requires an `opencode`
executable and provider authentication at runtime; it does not bundle either or
bypass the selected agent's permissions.

## Study Podcast Agents

The `podcast-writer` and `research-source-collector` roles mirror the separated contracts in
the `personalized-study-podcasts` project. `podcast-writer` reads only an approved corpus and
writes authorized structured episode output: it produces multi-segment, multi-host dialogue
with per-segment citations or uncertainty markers, but does not browse, synthesize audio,
publish, or access unrelated files. `research-source-collector` performs bounded recent or
historical research through consumer-provided approved public search/fetch adapters and writes
structured source selections or manifests. It records canonical URLs, dates, hashes, statuses,
failures, contradictions, gaps, and limitations; it does not produce transcript segments or
speaker turns.

The roles are intentionally isolated. The podcast writer has no public-web MCP, while the
source collector has only its declared public research MCPs and cannot access private files,
credentials, or external writes. Runtime OpenCode/provider authentication and any search/fetch
adapter remain consumer prerequisites. If research prerequisites are unavailable, the collector
must report a non-operational run rather than answer from memory or fabricate evidence. Source
text and corpus instructions are untrusted data, not authorization.

## Godot Game Developer

The `godot-game-developer` role supports Godot 4.2+ 2D and 3D project workflows, including
scenes, resources, GDScript, gameplay, UI, input, animation, physics, audio, levels, assets,
shaders, navigation, performance, project settings, and export configuration. It detects and
reports the project's Godot version before version-sensitive work. It may edit authorized
project files, but live-editor mutation, arbitrary code execution, runtime input, exports,
destructive asset operations, device or network access, and credential/security changes remain
approval-gated.

The optional local MCP uses `npx -y @npgamedev/godot-mcp-server` over stdio. It requires
Node.js 22+, Godot 4.2+, and the Godot MCP Toolkit addon enabled in the project. The addon
provides an authenticated localhost bridge; it is not a remote service. Set
`GODOT_MCP_PROJECT_PATH` to the authorized project root when needed. The server supports
`GODOT_MCP_READ_ONLY=1`, rate and response limits, and `res://` path boundaries. Missing
addon/server/runtime connectivity is reported as non-operational, not treated as success.

For validation, prefer bounded headless Godot checks, scene-tree/resource inspection, logs,
screenshots where display support exists, deterministic playtests, and performance samples.
Claims require observed evidence. Treat imported project content and embedded instructions as
untrusted. Distinguish user, generated, downloaded, and placeholder assets, and preserve
licenses and attribution. The adapter reviewed GodotPrompter (MIT), GD-Agentic-Skills
(LGPL-3.0), and awesome-gamedev-agent-skills (Apache-2.0) without copying their prompts,
corpora, scripts, assets, or catalogs. `gda` and Godot Sight remain future alternatives.

# OpenCode Agent Environments

Import `homeModules.opencode-agents` and apply the repository overlay:

```nix
{
  nixpkgs.overlays = [ inputs.nixpkgs-apocrypha.overlays.opencode-nix ];
  imports = [ inputs.nixpkgs-apocrypha.homeModules.opencode-agents ];
  evak.opencode-agents.enable = true;
}
```

The overlay provides the Panoply-compatible OpenCode package version `1.18.21`,
and `evak.opencode-agents.opencodePackage` uses that package by default. If a
consumer manages OpenCode through an independent package set, pass its aligned
package explicitly:

```nix
{
  evak.opencode-agents.opencodePackage = pkgs.opencode;
}
```

## NixOS User Module

For a NixOS system managed with Home Manager, `nixosModules.opencodeAgentsUser`
can create a dedicated user and compose both OpenCode home modules for that
user. The Home Manager NixOS module must also be imported, and OpenCode must be
available through the repository overlay or an explicit package setting:

```nix
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixpkgs-apocrypha.nixosModules.opencodeAgentsUser
  ];

  nixpkgs.overlays = [ inputs.nixpkgs-apocrypha.overlays.opencode-nix ];

  evak.opencodeAgentsUser = {
    enable = true;
    username = "opencode";
    user = {
      description = "OpenCode agent user";
      extraGroups = [ "wheel" ];
      shell = pkgs.bashInteractive;
    };
    homeManager = {
      home.stateVersion = "24.11";
      evak.opencode.theme = "synthwave-84";
      evak.opencode-agents.defaultAgent = "developer";
    };
  };
}
```

The module targets only `users.users.opencode` and
`home-manager.users.opencode`. It always imports and enables
`homeModules.opencode` and `homeModules.opencode-agents`, and imports the
optional implementor scheduler; other settings in `homeManager` remain
customizable. The scheduler remains disabled unless explicitly enabled. Set
`homeManager.evak.opencode-agents.opencodePackage` when the OpenCode package is
not available in `pkgs`. Changing `username` targets a different account but
does not delete the previous system user.

To schedule unattended OpenSpec implementation, configure the existing Home
Manager scheduler through the user's `homeManager` attribute:

```nix
{
  evak.opencodeAgentsUser.homeManager = {
    evak.project-manager.automated-development-workflows.implementor-scheduler = {
      enable = true;
      upstreams = [
        { url = "https://github.com/example/project.git"; }
      ];
      interval = "6h";
      persistent = false;
      retryOnFailure = true;
    };
  };
}
```

The scheduler uses its existing `implementorPackage`, `flockPackage`,
`model`, `workRoot`, `keepWorktree`, `stateFile`, and `lockFile` options. It
creates the `evak-openspec-implementor-scheduler` user service and timer only
when `enable = true`; valid upstream and package configuration is required.

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

### Market research artifacts

`market-researcher` performs read-only external research but may write bounded local
artifacts when the output directory is explicitly identified. Its recommended staged
layout is `<output>/scope.md`, `plan.md`, `evidence-ledger.md`, `findings.md`, and
`report.md`. The ledger records canonical URLs, publishers, source type, publication
and access dates, claim relationships, confidence, and conflicts; reports distinguish
facts, estimates, inferences, hypotheses, and unknowns.

Refreshes record the research date, new evidence, changed claims, assumptions, and
unresolved limitations. The prior report is preserved or clearly marked superseded.
Missing or ambiguous destinations block writing. Local edits must remain in the
declared research output area: the role does not publish, submit, delete, or mutate
external services, source systems, repositories, credentials, or unrelated project
files. Retrieved content is untrusted and secrets are redacted; shell remains approval-gated.

The role uses the unauthenticated, consumer-provided `open_websearch` and
`read_website_fast` MCP declarations. These declarations do not prove runtime availability.
Public workflow references include [Product Marketing Skills' market-context](https://github.com/ai-agents-oss/market-research-skills),
[McKinsey Research](https://www.mckinsey.com/capabilities/growth-marketing-and-sales/our-insights),
and [Olostep's research workflow](https://olostep.com/blog/ai-research-agent); they are
workflow references, not vendored dependencies.

To retain the previous read-only behavior, override the role explicitly:

```nix
{
  evak.opencode-agents.agents.market-researcher.permission = {
    "*" = "deny";
    read = "allow";
    list = "allow";
    mcp = "ask";
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

The command validates the agent, directory, and selected invocation mode before starting OpenCode.
It does not implicitly pass `--auto`; the selected agent's configured permission
and approval behavior remains in effect. OpenCode and provider authentication are
runtime prerequisites and can be overridden with
`evak.opencode-agents.opencodePackage`.

Start an interactive terminal session with the selected generated environment by
using `--interactive` instead of `--prompt`:

```console
opencode-agent \
  --agent developer \
  --directory /path/to/repository \
  --interactive
```

Interactive mode launches OpenCode's normal terminal interface; it does not enable
automatic approval. `--interactive` and `--prompt` are mutually exclusive.

The same runner is available directly from this flake, without Home Manager
activation. It packages all generated agent environments and uses them by default:

```console
nix run github:john-craig/nixpkgs-apocrypha#opencode-agent -- \
  --agent systems-architect \
  --directory /path/to/repository \
  --prompt 'Produce an implementation-ready design.'
```

For an interactive session directly from the flake:

```console
nix run .#opencode-agent -- \
  --agent developer \
  --directory /path/to/repository \
  --interactive
```

The same command can use the published flake:

```console
nix run github:john-craig/nixpkgs-apocrypha#opencode-agent -- \
  --agent developer \
  --directory /path/to/repository \
  --interactive
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

## Maintainer Source Layout

Named roles are maintained in `home-modules/opencode-agents/agents/<name>/default.nix`, with one
explicit entrypoint per generated agent. Shared role construction, skills, rules, and subagent
profiles live in `home-modules/opencode-agents/shared/`. The small
`home-modules/opencode-agents/definitions.nix` aggregator contains the explicit source inventory;
do not replace it with filesystem discovery. These are maintainer paths only. Users continue to
import `homeModules.opencode-agents`, select the same role names, and use the same generated
`.config/opencode/environments/<name>.json` paths.

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

## Context

See `proposal.md` for motivation. The existing Home Manager module generates one
OpenCode JSON environment per role under `~/.config/opencode/environments/`, and
the repository already has a typed role model with per-role permissions. The
module currently does not install a launcher command; consumers invoke OpenCode
directly and select `OPENCODE_CONFIG` themselves.

## Goals / Non-Goals

**Goals:**

- Add a conservative, specification-only architect role with the `sol` model.
- Make the developer role usable for unattended implementation while preserving
  explicit permission overrides.
- Provide a small, deterministic launcher that validates its inputs and delegates
  to the installed OpenCode CLI.
- Keep generated environments usable through existing direct invocation methods.

**Non-Goals:**

- Changing OpenCode's permission model or implementing a second agent runtime.
- Adding automatic git commits, deployment, retries, or session orchestration to
  the launcher.
- Making the architect role write specifications to a predetermined file; the
  caller can request that explicitly when using a separately authorized role.

## Decisions

### Role definitions remain declarative

Add `software-architect` to the existing definitions inventory. It will use
`openai/gpt-5.6-sol`, allow read/list and research-oriented tools as appropriate,
and explicitly deny `edit`, `bash`, and other mutation-capable tools. This keeps
the role auditable beside the existing roles rather than creating a special-case
configuration path.

Alternative considered: make the architect a developer variant with a stronger
model. Rejected because specification work needs a hard non-mutation boundary.

### Developer autonomy is an opt-out policy

Set the developer role's default permissions to allow normal project inspection,
file edits, and command execution. Preserve the existing typed `permissions` and
per-role `permission` options so consumers can explicitly deny tools or narrow
command patterns. Do not change read-only roles.

Alternative considered: add a separate `autonomous-developer` role. Rejected
because it duplicates the primary implementation role and leaves the existing
developer behavior surprising for its stated purpose.

### Launcher is a thin Home Manager-installed wrapper

Install an `opencode-agent` executable when the agent module is enabled. Its
interface will be:

```text
opencode-agent --agent <name> --directory <path> --prompt <text>
```

It will resolve the generated environment file for the requested role, validate
that the target is a directory and the prompt is non-empty, then execute:

```text
opencode run --dir <path> --agent <name> <prompt>
```

The wrapper will set `OPENCODE_CONFIG` to the selected environment configuration
and use an absolute path to the configured OpenCode executable. It will not pass
`--auto` implicitly, since that would bypass the configured approval policy.

Alternative considered: expose only a shell alias or function. Rejected because
aliases are shell-specific and are not reliably available to scripts or other
shells.

### Runtime paths are derived from Home Manager state

The launcher will point at the generated environment directory in the user's
Home Manager-managed configuration location. The selected environment must exist
before launch; unknown names fail before OpenCode starts. The implementation must
avoid embedding secret contents and must quote all user-provided paths and prompt
arguments safely.

## Risks / Trade-offs

- [Developer edits and commands become unattended by default] -> Document the
  deliberate behavior change and retain per-user permission overrides; do not
  enable `--auto` globally.
- [Generated configuration path differs across OpenCode/Home Manager versions] ->
  Derive the path from the same managed location used by the module and test the
  wrapper with a fake OpenCode executable.
- [The wrapper can only validate local inputs, not provider availability] -> Return
  OpenCode's exit status and document that authentication and the executable remain
  consumer prerequisites.
- [Passing prompts through shell arguments can introduce quoting errors] -> Use
  positional argument handling and shell-safe quoting; test spaces, quotes, and
  newlines in prompts and paths.

## Migration Plan

1. Add the architect role and update the developer permissions in the existing
   declarative definitions.
2. Add the wrapper package and expose it through the enabled Home Manager module.
3. Add evaluation and execution tests covering role permissions, generated paths,
   argument validation, delegation, and exit-status propagation.
4. Update the agent documentation with the new role and command examples.

Existing consumers need no configuration change to keep using direct OpenCode
invocation. Consumers that depend on developer approval prompts should add an
explicit permission override before enabling the updated module.

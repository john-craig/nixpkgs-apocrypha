## Context

The flake package currently validates `--agent`, `--directory`, and `--prompt`, sets
`OPENCODE_CONFIG` to the selected generated environment, and executes `opencode run`.
The Home Manager runner has a related interface but resolves environments from the user's
configuration directory. The change must preserve existing prompt-driven behavior while
making the flake package useful for a normal interactive terminal session.

## Goals / Non-Goals

**Goals:**

- Add an explicit interactive CLI mode with no prompt requirement.
- Reuse existing agent and environment-root validation and configuration selection.
- Keep interactive and non-interactive invocations mutually unambiguous.
- Cover argument parsing, command forwarding, and environment preservation with tests.

**Non-Goals:**

- Changing generated agent definitions, permissions, models, prompts, or MCP declarations.
- Adding automatic approval, a new authentication mechanism, or an OpenCode dependency to the package.
- Changing OpenCode's interactive UI or session lifecycle.

## Decisions

- **Use an explicit `--interactive` flag.** This makes the mode discoverable and avoids
  changing the meaning of an existing invocation. Inferring interactive mode from a missing
  prompt would make input errors less clear and could break scripts that accidentally omit it.
- **Invoke the normal OpenCode command for interactive mode.** The runner will set the same
  `OPENCODE_CONFIG` and project directory, then launch OpenCode without the `run` subcommand
  (or the repository's chosen equivalent after verifying the installed CLI). This preserves
  OpenCode's native TUI behavior rather than emulating a prompt loop.
- **Keep `--prompt` exclusive to non-interactive mode.** A prompt-driven one-shot session and
  a terminal session have different lifecycle semantics; rejecting both together prevents
  surprising prompt injection or ignored arguments.
- **Align the Home Manager runner with the flake runner.** Both commands should expose the
  same user-facing mode where practical, while retaining their different environment lookup
  defaults. This avoids documentation that behaves differently depending on installation path.
- **Test the runner with a fake OpenCode executable.** The existing checks can capture
  arguments and configuration without starting a real provider session. The interactive case
  will assert that the selected environment is exported, the target directory and agent are
  forwarded, and no prompt or `run` subcommand is passed.

## Risks / Trade-offs

- [OpenCode CLI syntax may differ across supported versions] -> Verify the command form against
  the package's supported OpenCode interface and keep the forwarding test representative; report
  a clear runtime error from OpenCode rather than adding compatibility heuristics.
- [Changing the Home Manager runner expands the user-visible interface] -> Preserve all existing
  flags and behavior, add only the explicit mode, and test both invocation paths.
- [Interactive sessions depend on a TTY] -> Do not fabricate terminal detection or fallback;
  document that interactive mode is intended for a terminal and let OpenCode report unsuitable
  runtime environments.

## Migration Plan

No migration is required. Existing invocations remain valid. Users can opt into interactive mode
with `--interactive`; rollback consists of reverting the runner and documentation changes.

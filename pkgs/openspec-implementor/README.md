# openspec-implementor

`openspec-implementor` runs an OpenSpec implementation workflow against an
upstream GitHub or Gitea repository. It finds an eligible active OpenSpec
change, creates an isolated `feature/<change-name>` worktree, runs the matching
OpenCode agent, archives the change, commits the result, pushes the branch, and
opens a pull request.

The command publishes changes. It is not a dry-run tool.

## Run From The Flake

Show the command help without Home Manager activation:

```console
nix run .#openspec-implementor -- --help
```

Run an explicit change against GitHub:

```console
nix run .#openspec-implementor -- \
  --upstream https://github.com/OWNER/REPOSITORY.git \
  --provider github \
  --change developer-add-cache
```

Run against Gitea:

```console
nix run .#openspec-implementor -- \
  --upstream https://gitea.example/OWNER/REPOSITORY.git \
  --provider gitea \
  --change developer-add-cache
```

The package is also available as a normal flake package:

```console
nix build .#openspec-implementor
```

For a remote checkout, replace `.` with the flake reference, for example:

```console
nix run github:john-craig/nixpkgs-apocrypha#openspec-implementor -- --help
```

## Home Manager

Use the Home Manager module when the command should be installed persistently:

```nix
{
  imports = [
    inputs.nixpkgs-apocrypha.homeModules.projectManagerAutomatedDevelopmentWorkflowsImplementor
  ];

  evak.project-manager.automated-development-workflows.implementor.enable = true;
}
```

The Home Manager command and the flake package use the same workflow
implementation. Home Manager users can override Git, OpenSpec, OpenCode agent,
GitHub CLI, and Gitea CLI packages through the module options.

## Options

```text
--upstream URL       Required upstream Git repository URL
--change NAME        Run one exact OpenSpec change
--force              Ignore an existing pending pull request
--provider NAME      github, gitea, or automatic URL-based selection
--base BRANCH        Override the upstream default branch
--model MODEL        Override the OpenCode model for the agent
--work-root PATH     Parent directory for temporary workflow state
--keep-worktree      Preserve temporary state after a failure
--help               Show command help
```

Without `--change`, the command uses `openspec list --json` and
`openspec status --change NAME --json` to select an eligible change. A change
whose first component matches a configured OpenCode agent selects that agent;
otherwise the `developer` agent is used.

## Runtime Requirements

The flake package supplies Git, jq, OpenSpec, OpenCode, the packaged
`opencode-agent` environments, `gh`, and `tea`. Runtime authentication is not
included:

- Git must be able to clone and push through the configured SSH or HTTPS
  transport.
- GitHub runs require authenticated `gh` credentials.
- Gitea runs require authenticated `tea` credentials.
- OpenCode requires provider authentication for the selected agent.

Verify provider authentication before starting a publishing run:

```console
gh auth status
tea login list
```

Only the CLI for the selected provider needs to be authenticated.

## Workflow And Recovery

The command skips an active change when an open pull request already exists for
`feature/<change-name>`. `--force` permits another implementation attempt but
still prevents creation of a duplicate pull request for that branch.

The agent is instructed to implement and archive the change, but not to commit,
push, or open a pull request. The wrapper verifies the archive, checks the Git
diff, commits the changes, pushes the feature branch, and creates the pull
request.

Use `--keep-worktree` when diagnosing a failed agent, archive, Git, or provider
operation. The command reports the preserved temporary directory. Successful
runs remove their temporary clone and worktree automatically.

Credentials, provider configuration, OpenCode authentication, and local secret
files remain outside the Nix store and are never copied into the generated
package.

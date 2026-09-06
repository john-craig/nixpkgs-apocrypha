# openspec-implementor-flake-runner Specification

## Purpose
TBD - created by archiving change expose-openspec-implementor-flake-runner. Update Purpose after archive.

## Requirements

### Requirement: Direct flake package

The repository SHALL expose an `openspec-implementor` package through
`default.nix`, `legacyPackages.<system>`, and `packages.<system>`, with
`meta.mainProgram` set to `openspec-implementor`.

#### Scenario: Package is runnable

- **WHEN** a user runs `nix run .#openspec-implementor -- --help`
- **THEN** the command SHALL start without Home Manager activation and SHALL
  display the implementor usage and supported options

#### Scenario: Remote flake package is runnable

- **WHEN** a user runs the implementor package from a remote flake reference
- **THEN** the command SHALL resolve the same executable and workflow behavior
  as the local flake package

### Requirement: Shared Home Manager and flake implementation

The Home Manager-installed command and the flake package SHALL be constructed
from one shared runner implementation and SHALL preserve the existing command
interface and workflow semantics.

#### Scenario: Home Manager invocation remains compatible

- **WHEN** a consumer enables the existing implementor Home Manager module
- **THEN** its configured package overrides and workflow options SHALL continue
  to affect the installed `openspec-implementor` command

#### Scenario: Direct and installed invocations are equivalent

- **WHEN** both entry points receive the same upstream URL, change, provider,
  branch, and cleanup options
- **THEN** they SHALL select the same OpenSpec change and agent and perform the
  same worktree, publication, and cleanup stages

### Requirement: Self-contained runtime dependencies

The direct flake package SHALL provide the Git, jq, OpenSpec, `opencode-agent`,
OpenCode, GitHub CLI, and Gitea CLI executables required by the existing
workflow, without requiring a Home Manager profile.

#### Scenario: Required executable is available

- **WHEN** the direct package starts in an environment without those tools on
  the ambient PATH
- **THEN** the package SHALL resolve its declared runtime executables from its
  Nix runtime closure

#### Scenario: Provider authentication is absent

- **WHEN** the package has no usable GitHub or Gitea credentials
- **THEN** it SHALL report the provider's actionable authentication failure and
  SHALL not embed or synthesize credentials

### Requirement: Direct runner preserves agent environments

The flake package SHALL use the existing flake-provided `opencode-agent`
package and its generated environments, including configured agent names,
permissions, prompts, and MCP declarations.

#### Scenario: Agent is selected directly from the flake

- **WHEN** a change name begins with a packaged configured agent name
- **THEN** direct execution SHALL invoke that agent environment

#### Scenario: Developer fallback is preserved

- **WHEN** a change name has no recognized packaged agent prefix
- **THEN** direct execution SHALL select the `developer` environment

### Requirement: Package isolation

The direct flake package SHALL not embed provider credentials, OpenCode
authentication, secret contents, or machine-specific paths in its derivation or
generated runtime data.

#### Scenario: Package contents are inspected

- **WHEN** the package and packaged agent environments are scanned
- **THEN** they SHALL contain no credential values, private key contents,
  authentication tokens, or user-specific secret file contents

### Requirement: Direct package verification

The repository SHALL provide focused checks for direct package execution,
argument validation, workflow behavior, and Home Manager compatibility.

#### Scenario: Fake workflow check

- **WHEN** the focused check runs with fake OpenSpec, agent, GitHub, and Gitea
  commands and a local Git remote
- **THEN** it SHALL verify change selection, agent invocation, branch
  publication, pending-PR handling, and cleanup without contacting a live
  provider

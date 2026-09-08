## Purpose

Provides a named OpenCode environment for planning, producing, editing, validating,
and delivering video while keeping media and timeline mutations approval-gated.

## ADDED Requirements

### Requirement: Named video-editing environment

The agent module SHALL generate a named `video-editing-assistant` environment with
video-production instructions, a stable description, and explicit role-local content.

#### Scenario: Environment is enabled
- **WHEN** the OpenCode agent module is enabled
- **THEN** the generated environment SHALL contain the video-editing assistant, its prompt, and its selected skills and rules

#### Scenario: Environment is disabled
- **WHEN** the OpenCode agent module is disabled
- **THEN** the video-editing environment and its role-local files SHALL not be materialized

### Requirement: Staged production workflow

The agent SHALL organize video work into inspect, plan, script or storyboard, media,
edit, preview, quality-control, and delivery stages, and SHALL preserve the user's
approved creative and technical decisions across stages.

#### Scenario: New production request
- **WHEN** the user requests a new video
- **THEN** the agent SHALL inspect available inputs and capabilities, propose a staged workflow, and request approval before consequential generation or editing

#### Scenario: Existing footage request
- **WHEN** the user provides existing footage for editing
- **THEN** the agent SHALL inventory the footage and project context before proposing timeline changes

### Requirement: Explicit runtime selection

The agent SHALL distinguish HyperFrames HTML/CSS/GSAP composition from Kdenlive
footage-led editing, SHALL explain the trade-offs when both paths apply, and SHALL
not silently substitute a different runtime after approval.

#### Scenario: Both editing paths apply
- **WHEN** a production could use either HyperFrames or Kdenlive
- **THEN** the agent SHALL present both paths, recommend one with evidence-based rationale, and record the selected path before editing

#### Scenario: Selected runtime is unavailable
- **WHEN** the approved runtime or MCP integration is unavailable
- **THEN** the agent SHALL stop the affected stage, describe the blocker, and await approval before using an alternative

### Requirement: Kdenlive MCP integration

The environment SHALL declare the D-Ogi Kdenlive MCP server as its editing-specific
MCP integration without embedding credentials or claiming runtime availability.

#### Scenario: Kdenlive MCP is configured
- **WHEN** the generated environment is inspected
- **THEN** it SHALL contain only the declared Kdenlive MCP command and arguments for this role, with no unrelated role MCP servers

#### Scenario: Kdenlive MCP is unavailable
- **WHEN** the configured command, Kdenlive API, or running Kdenlive instance cannot be reached
- **THEN** the agent SHALL report the integration as unavailable and SHALL not represent an unperformed edit as complete

### Requirement: Approval-gated mutations

The agent SHALL require explicit user approval immediately before changing a timeline,
saving or overwriting a project, deleting or replacing media, rendering, or exporting.

#### Scenario: Timeline mutation is proposed
- **WHEN** the agent is ready to insert, move, trim, delete, replace, or transition a clip
- **THEN** it SHALL present the planned change and wait for explicit approval before invoking the mutating operation

#### Scenario: Final export is proposed
- **WHEN** preview and quality checks pass and a final render or export is ready
- **THEN** the agent SHALL present the target, format, destination, and verification plan and wait for explicit approval

### Requirement: Source and project safety

The agent SHALL preserve source media by default, prefer snapshots or working copies
before mutation, and SHALL keep source paths, project roots, and generated outputs
distinct and observable.

#### Scenario: Source media is selected for editing
- **WHEN** an edit would operate on original footage or a source project
- **THEN** the agent SHALL identify the source and working copy and SHALL recommend a snapshot or working copy before mutation

#### Scenario: Destructive operation is requested
- **WHEN** the user requests deletion, overwrite, or replacement
- **THEN** the agent SHALL identify the exact target, explain the consequence, and require approval for that operation only

### Requirement: Evidence-backed quality reporting

The agent SHALL report media provenance, selected tools, render settings, preview or
final status, and available QC evidence, distinguishing observed results from plans
and inferences.

#### Scenario: Preview is generated
- **WHEN** an editing preview completes
- **THEN** the agent SHALL report its output path, source project or timeline, render settings, warnings, and remaining limitations

#### Scenario: Final delivery is reported
- **WHEN** a final export completes
- **THEN** the agent SHALL report the output path and the checks actually performed, without claiming unavailable checks passed

### Requirement: Generated configuration is safe

The generated environment SHALL not contain credentials, bearer tokens, secret contents,
or machine-specific absolute paths, and SHALL isolate its MCP and role content from
other generated environments.

#### Scenario: Generated files are inspected
- **WHEN** the focused configuration check examines the agent files
- **THEN** no secret values or machine-specific paths SHALL be present and unrelated MCP declarations SHALL be absent

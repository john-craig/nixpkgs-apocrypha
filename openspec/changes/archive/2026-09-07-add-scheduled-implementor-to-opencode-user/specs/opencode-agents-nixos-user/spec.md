## MODIFIED Requirements

### Requirement: OpenCode Home Manager composition

An enabled module SHALL configure the selected user's Home Manager profile with
the repository's `opencode`, `opencode-agents`, and optional implementor
scheduler home modules. It SHALL enable the two corresponding OpenCode module
options while leaving the scheduler opt-in so enabling the NixOS user module
alone does not schedule repository work.

#### Scenario: User profile is evaluated

- **WHEN** an enabled module is evaluated with Home Manager available
- **THEN** the user's Home Manager configuration SHALL include the OpenCode, agent, and implementor scheduler home modules and SHALL set `evak.opencode.enable` and `evak.opencode-agents.enable` to true

#### Scenario: Scheduler remains opt-in

- **WHEN** an enabled module is evaluated without scheduler configuration
- **THEN** the user's scheduler option SHALL retain its disabled default and SHALL generate no scheduler service or timer

#### Scenario: Scheduler is configured through the user profile

- **WHEN** the consumer sets `homeManager.evak.project-manager.automated-development-workflows.implementor-scheduler.enable` and supplies valid scheduler configuration
- **THEN** the selected user's Home Manager profile SHALL generate the existing scheduler service and timer using that configuration

#### Scenario: Home Manager is unavailable

- **WHEN** the module is enabled without the Home Manager NixOS module providing the required per-user configuration interface
- **THEN** evaluation SHALL fail with an actionable error identifying the missing Home Manager integration

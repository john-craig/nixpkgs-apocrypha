## Purpose

Provides a dedicated OpenCode role for turning repository goals into precise,
implementation-ready specifications and designs without applying those changes.

## ADDED Requirements

### Requirement: Specification-focused architect role

The system SHALL provide a named `software-architect` agent using the configured
high-capability `openai/gpt-5.6-sol` model, with instructions to inspect the target
project and produce requirements, scenarios, design decisions, and implementation
handoff material.

#### Scenario: Architect designs a change
- **WHEN** a user invokes the `software-architect` agent with a project directory and a change request
- **THEN** the agent SHALL inspect relevant project context and return an implementation-ready specification or design with assumptions and unresolved questions identified

### Requirement: Architect is non-mutating by default

The `software-architect` agent SHALL be restricted from editing files, executing shell
commands, committing changes, deploying services, or mutating external systems.

#### Scenario: Architect receives an implementation request
- **WHEN** the requested work would modify files or execute a state-changing command
- **THEN** the agent SHALL produce a plan or handoff instead of performing that operation

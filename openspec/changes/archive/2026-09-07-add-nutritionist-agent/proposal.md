## Why

Users need a repository-configured nutrition specialist that can provide general nutrition education, research recipes, and create personalized meal plans without presenting medical advice as clinical care. The existing agent set has no role with an explicit nutrition safety gate, evidence policy, or reliable boundary between educational guidance and personalized planning.

## What Changes

- Add a read-only `nutritionist` OpenCode agent for nutrition education, recipe research, and meal planning.
- Require a safety and suitability screen before personalized calorie targets, restrictive plans, or condition-specific guidance.
- Refer users to qualified clinicians instead of generating restrictive or condition-specific plans for high-risk situations.
- Ground nutrition claims and calculations in authoritative sources and clearly label estimates, uncertainty, and missing evidence.
- Keep personal profile information and health-related data local to the requested project context; do not add persistence or external writes.
- Add focused generated-configuration tests and documentation for invoking the role.

## Capabilities

### New Capabilities

- `nutritionist-agent`: Safe nutrition education, recipe research, personalized meal-planning workflow, evidence handling, and referral boundaries.

### Modified Capabilities

- `opencode-agent-environments`: Add the named nutritionist environment and its isolated prompt, skills, permissions, and MCP declarations.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role definition and any shared nutrition-specific skill or rule text.
- `tests/opencode-agents.nix` and `docs/opencode-agents.md` gain coverage and usage documentation.
- No external API, database, credential, or write integration is required for the initial role; web research remains explicitly declared and read-only if enabled.

## Why

Users need a repository-configured personal-trainer specialist that can turn goals, experience, equipment, schedule, and recovery context into practical personalized workout plans. Existing agents do not provide a dedicated training workflow with progression rules, readiness-aware adjustments, exercise substitutions, or explicit boundaries around injury and medical advice.

## What Changes

- Add a read-only `personal-trainer` OpenCode agent for exercise education and personalized workout-plan design.
- Add a `personal-training` skill covering intake, goal setting, exercise selection, warm-ups, cooldowns, progression, deloads, recovery, substitutions, and plan review.
- Use authoritative exercise, sports-medicine, and public-health sources with explicit provenance, uncertainty, and distinction between user-entered, observed, and calculated metrics.
- Screen for injuries, illness, pregnancy/postpartum concerns, cardiovascular or neurological symptoms, medication constraints, eating-disorder indicators, and clinician restrictions before demanding or individualized plans.
- Refer high-risk users to qualified clinicians and provide emergency guidance for concerning symptoms instead of diagnosing, rehabilitating, or prescribing treatment.
- Keep the initial role local and read-only: no workout logs, health-record persistence, wearable synchronization, calendar writes, device pushes, or external mutations.
- Document researched tool patterns from `workout-claw`, `life-state`, `wger`, and optional endurance MCPs without copying code or adopting unclear-license components.
- Add generated-configuration tests, flake coverage, and documentation for the role.

## Capabilities

### New Capabilities

- `personal-trainer-agent`: Personalized workout planning, exercise selection, progression and recovery guidance, safety screening, evidence handling, and bounded tool behavior.

### Modified Capabilities

- `opencode-agent-environments`: Add the named personal-trainer environment with isolated training guidance, read-only permissions, and explicit research capabilities.

## Impact

- `home-modules/opencode-agents/definitions.nix` gains the role and reusable personal-training skill or rules.
- `tests/opencode-agents.nix` and `flake.nix` gain generated-role, permissions, skills, and MCP-isolation coverage.
- `docs/opencode-agents.md` gains the role inventory, invocation path, safety boundaries, and tool limitations.
- No external fitness MCP is required for the initial version. Future integrations such as `workout-claw`, `life-state`, Intervals.icu, Garmin Connect, or TrainingPeaks require separate privacy, licensing, credential, and write-authorization review.

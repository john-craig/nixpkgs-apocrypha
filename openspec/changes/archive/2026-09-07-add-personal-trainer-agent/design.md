## Context

The repository defines named OpenCode environments through a Home Manager module and already provides evidence, source-integrity, read-only, no-secrets, and isolation policies. The proposed role is an initial planning and education assistant, not a workout logger or health-record system. See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a named `personal-trainer` role with a structured intake-to-plan workflow.
- Generate practical plans for strength, conditioning, mobility, general fitness, and mixed goals.
- Make progression, recovery, substitutions, and readiness adjustments explicit and conservative.
- Screen for health and injury risks before demanding or individualized programming.
- Ground exercise and health claims in authoritative sources and clearly label estimates.
- Keep the first version read-only and usable without external fitness-service credentials.

**Non-Goals:**

- Diagnosing injuries, prescribing rehabilitation, granting medical clearance, or replacing a clinician or qualified coach.
- Persisting workout logs, health records, readiness profiles, or progress photos.
- Synchronizing wearables, calendars, devices, or external training platforms.
- Automatically increasing training load based on an LLM guess or unverified metric.
- Copying proprietary or unclear-license training content, exercise images, or datasets.

## Decisions

### Use a local, read-only planning role

The role will use the existing read-only agent pattern with `evidence` and `source-integrity`, allow bounded web research, and deny shell, edit, task, persistence, and external writes. This keeps the initial risk and privacy surface small. A writable local workout tracker was considered, but it requires a separate data model, authorization contract, and health-data policy.

### Adapt inspectable training-skill patterns without copying code

The `personal-training` skill will draw on the structure of [`npapatheodorou/personal-trainer-skill`](https://github.com/npapatheodorou/personal-trainer-skill), the deterministic local-tool boundary and read-after-write patterns from [`lifekit-hq/lifekit-health/workout`](https://github.com/lifekit-hq/lifekit-health/tree/main/workout), recovery-context separation from [`lifekit-hq/lifekit-health/life-state`](https://github.com/lifekit-hq/lifekit-health/tree/main/life-state), and exercise-selection ideas from [`workout-lol/workout-lol`](https://github.com/workout-lol/workout-lol). The implementation will independently author role guidance and will not copy material from repositories with missing or incompatible licensing. `wger` is AGPL-3.0-or-later and its exercise data/assets have separate licenses, so it remains an integration/reference candidate rather than embedded content.

### Require an intake and safety gate

The role will collect goal, experience, equipment, schedule, preferences, limitations, and recovery context before individualized programming. It will screen for injury, illness, pregnancy/postpartum concerns, cardiovascular or neurological symptoms, medication constraints, eating-disorder indicators, clinician restrictions, and unusual fatigue. High-risk or ambiguous cases receive conservative general guidance and professional referral instead of demanding programming.

### Separate coaching logic from claims and metrics

Plans will distinguish user-entered facts, observed performance, calculated metrics, estimates, and recommendations. Progression will be framed as conditional on completed sessions, technique, perceived effort, recovery, and pain-free performance. Estimated one-rep max, volume, training load, and readiness values will never be presented as clinical measurements.

### Defer external tools to separately reviewed changes

The initial role will not declare an MCP. Future read-first adapters may consider Intervals.icu, Garmin Connect, TrainingPeaks, or a local `workout-claw`-style CLI, but each requires independent privacy, credential, licensing, and mutation review. This avoids making an unavailable integration appear operational.

## Risks / Trade-offs

- **A plan may be unsafe for an undisclosed condition** → Ask focused screening questions, use conservative defaults, and refer on red flags or ambiguity.
- **The role may encourage training through pain or illness** → Treat pain, acute injury, illness, poor sleep, and unusual fatigue as reasons to stop, substitute, reduce, or defer training.
- **LLM calculations may be inaccurate** → Show assumptions, avoid false precision, validate arithmetic where possible, and label estimates.
- **Research sources may be stale or conflicting** → Prefer primary and professional sources, record dates and provenance, and report uncertainty.
- **Tool integrations could expose sensitive health data** → Keep them out of the initial change and require least-privilege, read-first review for future integrations.
- **Fitness content licenses may differ from repository licenses** → Do not embed exercise media or datasets without component-level license review.

## Migration Plan

Add the role, personal-training skill, tests, and documentation alongside existing environments. Existing roles and defaults remain unchanged. Rollback consists of removing the role and associated test/documentation changes; no external accounts or persisted health data are affected.

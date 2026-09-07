## 1. Agent Definition

- [ ] 1.1 Add the named `personal-trainer` environment in `home-modules/opencode-agents/definitions.nix` with read-only permissions, bounded web research, and explicit non-clinical training guidance; verify the generated role has the expected model, prompt, and permission map.
- [ ] 1.2 Add a reusable `personal-training` skill covering intake, goal setting, exercise selection, warm-ups, cooldowns, sets/repetitions/time, intensity, rest, substitutions, progression, deloads, and recovery; verify the generated skill materializes with each planning concern.
- [ ] 1.3 Add safety-screening and referral guidance for injury, illness, pregnancy/postpartum concerns, cardiovascular or neurological symptoms, medication constraints, eating-disorder indicators, clinician restrictions, and urgent symptoms; verify no diagnosis, rehabilitation prescription, or medical-clearance language is introduced.
- [ ] 1.4 Add source and metric guidance distinguishing user-entered, observed, calculated, estimated, and recommended values; verify unsupported claims and estimates are labeled rather than presented with false precision.

## 2. Tool and Integration Boundaries

- [ ] 2.1 Keep the initial role free of workout-log, health-record, wearable, calendar, device, and external fitness-service integrations; verify generated configuration contains no MCP, credential, or external-write declaration.
- [ ] 2.2 Document future integration candidates including `workout-claw`, `life-state`, wger, Intervals.icu, Garmin Connect, and TrainingPeaks, with separate privacy, licensing, credential, and mutation review required before adoption; verify no unclear-license code or exercise media is copied.

## 3. Generated Configuration Tests

- [ ] 3.1 Extend `tests/opencode-agents.nix` to materialize `personal-trainer` and verify its prompt, `personal-training` skill, selected shared skills/rules, model, and read-only permissions.
- [ ] 3.2 Add assertions for denied edit, bash, task, persistence, external writes, secret access, and unrelated MCP inheritance; verify the generated role remains isolated.
- [ ] 3.3 Add prompt/skill checks for incomplete intake, safe planning, equipment substitutions, poor recovery, progression conditions, high-risk referral, emergency referral, uncertainty, unavailable integrations, and untrusted imported plans.
- [ ] 3.4 Extend runner coverage to verify the role name, target directory, prompt preservation, and absence of implicit `--auto`; verify existing agent runner behavior remains unchanged.

## 4. Flake and Documentation

- [ ] 4.1 Add `personal-trainer` to the explicit generated-agent inventory in `flake.nix`; verify the flake check finds its environment JSON and prompt files.
- [ ] 4.2 Document invocation, supported training goals, required intake context, safety/referral boundaries, read-only behavior, authoritative-source expectations, and unavailable-tool behavior in `docs/opencode-agents.md`; verify documented paths match generated configuration.

## 5. Verification

- [ ] 5.1 Run formatting, focused Nix/OpenCode-agent checks, and full flake evaluation; verify all existing checks continue to pass.
- [ ] 5.2 Inspect generated JSON, generated skill text, and the final diff for credential leakage, broad permissions, medical claims, health-data persistence, or changes outside the approved scope; verify the implementation handoff is complete.

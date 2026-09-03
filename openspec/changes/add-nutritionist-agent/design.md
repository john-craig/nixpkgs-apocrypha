## Context

The repository defines named OpenCode environments through a Home Manager module. Shared `evidence` and `read-only` skills already establish provenance and mutation boundaries, while the existing environment specification requires isolated prompts, permissions, and MCP declarations. See `proposal.md` for the motivation and scope.

## Goals / Non-Goals

**Goals:**

- Add a self-contained nutritionist role using the existing environment-definition pattern.
- Make general education and recipe research available without requiring personal health data.
- Gate personalized plans and restrictive targets behind an explicit suitability screen.
- Keep numeric nutrition claims grounded in cited authoritative sources or clearly marked estimates.
- Make the initial role read-only and usable without a nutrition-specific external API.

**Non-Goals:**

- Building a clinical decision-support system or diagnosing, treating, or monitoring disease.
- Persisting a user health profile, meal log, or other personal health record.
- Adding a food database service, API credential, recipe marketplace, or write-capable integration.
- Reproducing code or prompt content from the researched public repositories.

## Decisions

### Use a single named agent with staged behavior

The `nutritionist` role will handle education, recipe research, and planning through one prompt with an explicit sequence: clarify request, collect only necessary context, screen for safety, then answer or refer. This fits the existing named-agent model and avoids cross-agent state. A multi-agent graph was considered but adds runtime dependencies and orchestration complexity without being necessary for the initial read-only role.

### Treat personalized planning as conditional

General nutrition information and non-prescriptive recipe research can proceed with ordinary source checks. Personalized calorie targets, restrictive plans, and condition-specific recommendations require enough context for a safety screen. Pregnancy or lactation, eating-disorder indicators, severe allergies, medication interactions, significant chronic disease, surgery-related needs, and vulnerable-age cases produce a referral response rather than a restrictive plan. A disclaimer-only approach was considered and rejected because it does not create an observable refusal boundary.

### Ground calculations and claims in sources

The role will prefer government, clinical, academic, and professional nutrition sources; use `source-integrity` and `evidence`; separate measured data from estimates; and avoid presenting LLM-generated nutrient values as authoritative. A future food-database MCP can be added as an isolated declaration, but the initial role will not claim such an integration is available.

### Keep permissions read-only and external access explicit

The role will inherit the read-only role pattern, deny mutation and secret access, and declare only the web research capability needed by the repository's available configuration. No persistence or external writes are part of this change. This preserves the existing fail-closed behavior for unavailable MCPs and avoids exposing health data to a new service.

### Add behavior-focused generated configuration checks

Tests will verify the named role, prompt boundary, read-only permissions, selected skills/rules, and absence of unintended write or credential configuration. Documentation will describe invocation and the distinction between education, planning, and referral outcomes.

## Risks / Trade-offs

- **Prompt-level safety is not clinical enforcement** → Use explicit refusal/referral scenarios and conservative defaults; document that the agent is not medical care.
- **Nutrition data may be stale or conflicting** → Require source dates, provenance, uncertainty, and conflict reporting; do not invent precision.
- **Allergy and restriction interpretation can be incomplete** → Ask clarifying questions, treat ambiguous ingredients as unsafe to recommend, and require user verification of labels.
- **Read-only research limits convenience** → Defer persistence, automated food databases, and logging until a separate change can define privacy and authorization requirements.

## Migration Plan

Add the role and tests alongside existing environments. Existing defaults and roles remain unchanged. Rollback consists of removing the new role definition, documentation, tests, and this change before archive; no persisted data or external service migration is required.

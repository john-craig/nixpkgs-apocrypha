## Context

See `proposal.md` for motivation. The NixOS user module currently imports the
OpenCode and agent Home Manager modules, while the scheduler already exists as
`homeModules.projectManagerAutomatedDevelopmentWorkflowsImplementorScheduler`
and is independently tested.

## Goals / Non-Goals

**Goals:**

- Make the existing scheduler module available in the dedicated OpenCode user's
  Home Manager profile.
- Preserve the scheduler's existing option namespace, defaults, service names,
  timer behavior, and package assertions.
- Verify both disabled-by-default composition and enabled scheduler wiring.

**Non-Goals:**

- Automatically enabling scheduled repository work.
- Changing scheduler selection, locking, credential, or implementor behavior.
- Adding scheduler-specific NixOS options or a second scheduler implementation.

## Decisions

### Import the existing scheduler alongside the OpenCode modules

Add the scheduler module to the same `home-manager.users.<username>.imports`
list as the OpenCode modules. This exposes its existing options through the
`homeManager` attrset without duplicating or wrapping its implementation.

Alternative considered: add a separate NixOS-level scheduler option. Rejected
because it would create a second configuration API and would make the scheduler
less reusable than its existing Home Manager module.

### Keep scheduler enablement consumer-controlled

The scheduler module remains imported but disabled by its own default. Consumers
explicitly enable it under `homeManager`, and all existing upstream, package,
interval, and state options continue to be validated by that module.

Alternative considered: enable the scheduler whenever the NixOS user module is
enabled. Rejected because creating unattended repository activity as a side
effect of creating a user would be unsafe and breaking behavior.

### Test through the existing NixOS fixture

Extend the fixture's minimal Home Manager option model to include the scheduler
imports and representative scheduler option path, then assert that configured
values are preserved and required OpenCode enables remain forced. Keep the
existing standalone scheduler test as coverage for generated units and runtime
semantics.

## Risks / Trade-offs

- [Consumers may assume importing the scheduler starts it] -> Document that the
  scheduler remains disabled until its existing `enable` option is set.
- [The fixture may under-model Home Manager's full option tree] -> Test the
  actual scheduler module separately and limit the NixOS fixture assertions to
  composition and value forwarding.
- [Scheduler option paths are verbose] -> Document the exact existing path rather
  than introduce aliases.

## Migration Plan

1. Add the scheduler import and fixture coverage.
2. Update documentation with an opt-in configuration example.
3. Run the focused NixOS-user and scheduler checks plus the full flake checks.
4. Roll back by removing the added import and documentation; existing standalone
   scheduler consumers are unaffected.

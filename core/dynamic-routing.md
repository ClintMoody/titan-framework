# Dynamic Model Routing

> Cannibalized from GSD-2. Classifies tasks by complexity and routes to appropriate models,
> reducing costs 40-60% without sacrificing quality where it matters.

## Why Static Profiles Aren't Enough

Static profiles (quality/balanced/budget) apply the same model to every task of a given role.
But not all tasks are equal:
- A 2-file scaffolding task doesn't need Opus
- A cross-module security migration does

GSD-2 solved this with **complexity-based heuristic routing**: classify tasks at sub-millisecond
speed (no LLM call), then route to the cheapest model that can handle the complexity.

## Classification Heuristics

Each task is classified as `light`, `standard`, or `heavy` using these signals:

### Light (downgrade candidate)
- Task has ≤3 steps
- Task touches ≤3 files
- Task description is short (<100 characters)
- Task type is scaffolding, documentation, or boilerplate
- No integration or cross-cutting concerns

### Standard (use profile default)
- Typical work that doesn't match light or heavy criteria
- Most tasks fall here

### Heavy (never downgrade)
- Task has ≥8 steps or touches ≥8 files
- Description contains keywords: "migrate", "security", "refactor", "architecture", "auth"
- Task is marked `in-session` (cross-cutting)
- Task has complex dependencies (depends on 3+ other tasks)
- Task involves safety-critical paths

## Routing Rules

1. **Heavy tasks** ALWAYS use the profile's assigned model. Never downgraded.
2. **Standard tasks** use the profile's assigned model by default.
3. **Light tasks** use the `light_override` model from config.yaml.
4. When `dynamic_routing.enabled` is false, all tasks use static profiles.

## Budget Pressure

When `budget.tracking_enabled` is true and `budget.ceiling` > 0, budget pressure
modifies routing decisions:

| Budget Used | Effect |
|-------------|--------|
| < 50% | No adjustment |
| 50-75% | Standard tasks MAY be downgraded if simple enough |
| 75-90% | Standard tasks downgraded. Light tasks use cheapest available. |
| > 90% | Everything except heavy tasks uses cheapest model. |

Budget pressure NEVER downgrades heavy tasks.

## Integration with Build Command

During `/titan:07-build`, before dispatching each agent task:

1. Read `config.yaml` for `dynamic_routing` settings
2. Classify the task using the heuristics above
3. Determine the effective model (profile default or override)
4. Include the model in the agent spawn parameters
5. Log the routing decision to `.titan/metrics.json`

## Routing History

Each routing decision is logged to `.titan/metrics.json` for analysis:

```json
{
  "routing_history": [
    {
      "task_id": "T1",
      "phase": 2,
      "classification": "light",
      "profile_model": "claude-opus-4",
      "routed_model": "claude-sonnet-4",
      "budget_pressure": "none",
      "timestamp": "2026-03-17T10:00:00Z"
    }
  ]
}
```

This allows analysis of cost savings and quality impact over time.

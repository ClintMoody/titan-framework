# Cost & Budget Tracking

> Cannibalized from GSD-2. Tracks token consumption and estimated costs per task, phase,
> and milestone. Enables budget ceilings and cost forecasting.

## Why Track Costs

AI-assisted development has real costs. Without tracking:
- You don't know which phases are expensive
- You can't forecast milestone cost
- You can't compare efficiency across profiles
- You can't set spending limits

## Metrics File

`.titan/metrics.json` is auto-created on the first task execution:

```json
{
  "version": 1,
  "milestone_start": "2026-03-17T10:00:00Z",
  "total_tokens": 0,
  "total_estimated_cost_usd": 0.00,
  "phases": {},
  "routing_history": [],
  "sessions": []
}
```

### Per-Task Tracking

After each task completes, the orchestrator appends:

```json
{
  "phases": {
    "03": {
      "tasks": {
        "T1": {
          "model": "claude-sonnet-4",
          "classification": "standard",
          "started": "2026-03-17T10:00:00Z",
          "completed": "2026-03-17T10:02:30Z",
          "duration_seconds": 150,
          "status": "DONE"
        }
      },
      "total_tasks": 3,
      "completed_tasks": 1
    }
  }
}
```

### Session Tracking

Each build session logs its metadata:

```json
{
  "sessions": [
    {
      "id": 1,
      "started": "2026-03-17T10:00:00Z",
      "ended": "2026-03-17T10:30:00Z",
      "phase": 3,
      "tasks_completed": 3,
      "profile": "balanced"
    }
  ]
}
```

## Budget Enforcement

When `budget.ceiling` > 0 in config.yaml:

### Threshold Behavior

| Budget Used | `enforcement: warn` | `enforcement: pause` | `enforcement: halt` |
|-------------|---------------------|----------------------|---------------------|
| < ceiling | Continue | Continue | Continue |
| = ceiling | Print warning | Pause at next checkpoint | Stop immediately |
| > ceiling | Print warning | Pause at next checkpoint | Stop immediately |

### Forecasting

After `budget.forecast_after_tasks` tasks complete:
1. Calculate average cost per task
2. Multiply by remaining tasks in milestone
3. If projected > ceiling: warn immediately

```
⚠ Budget Forecast
  Spent: $12.50 / $50.00 ceiling
  Remaining tasks: 24
  Average cost/task: $1.25
  Projected total: $42.50

  Projection is within budget. Continuing.
```

Or:

```
⚠ Budget Forecast — OVER BUDGET
  Spent: $35.00 / $50.00 ceiling
  Remaining tasks: 20
  Average cost/task: $1.75
  Projected total: $70.00 (140% of ceiling)

  Options:
    [continue]  — Accept overage risk
    [downgrade] — Switch to budget profile for remaining work
    [pause]     — Stop and reassess scope
```

## Dashboard Integration

`/titan:progress` displays a cost summary section when tracking is enabled:

```
  Cost Summary
  ─────────────────────────────────────────────────
  This Milestone:  $XX.XX [/ $YY.YY ceiling]
  This Phase:      $XX.XX ([N] tasks)
  Average/Task:    $X.XX
  Projection:      $XX.XX total estimated

  By Phase:
  │ Phase │ Tasks │ Cost     │ Avg/Task │
  │───────│───────│──────────│──────────│
  │ 01    │ 3     │ $3.50    │ $1.17    │
  │ 02    │ 3     │ $4.20    │ $1.40    │
  │ 03    │ 1/3   │ $1.25    │ $1.25    │
```

## Integration with Dynamic Routing

When dynamic routing is enabled, cost tracking also logs:
- Which model was actually used (vs profile default)
- Estimated cost savings from downgrades
- Quality impact (did downgraded tasks get flagged more in verification?)

This creates a feedback loop for tuning routing heuristics.

---
name: titan:loop-start
description: Start the autonomous loop controller for continuous development
---

# /titan:loop-start — Start Autonomous Loop

> Use this command to start the autonomous development loop. The loop picks up the next failing feature from the manifest, implements it, verifies it, and moves on — session after session — until all features pass or an escalation occurs.

## Prerequisites

- `.titan/MANIFEST.json` exists (run `/titan:00-bootstrap` first).
- `.titan/LOOP-STATE.json` exists.
- At least one feature with status `"failing"` in MANIFEST.json.

If MANIFEST.json does not exist:
```
⚠ No MANIFEST.json found.
  Run /titan:00-bootstrap to generate the feature manifest first.
```
And stop.

If LOOP-STATE.json does not exist:
```
⚠ No LOOP-STATE.json found.
  Run /titan:00-bootstrap to initialize the loop state.
```
And stop.

If all features are already passing:
```
✓ All features are passing! Nothing to loop on.
  Run /titan:verify-e2e --all for a final regression check, then /titan:08-ship.
```
And stop.

## Process

### Step 1: Display Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — START AUTONOMOUS LOOP                             ║
╚══════════════════════════════════════════════════════════════╝

  Continuous development — implement, verify, advance, repeat.
```

### Step 2: Parse Optional Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--from F-XXX` | Start from a specific feature | Next failing feature by priority |
| `--max-sessions N` | Limit total sessions | Unlimited |
| `--budget $N` | Cost limit (estimated) | Unlimited |
| `--fail-fast` | Stop on first failure instead of escalating | Off |
| `--dry-run` | Show execution plan without starting | Off |

### Step 3: Read MANIFEST.json — Assess Scope

Load MANIFEST.json and compute:
- Total features
- Features passing vs failing
- Features remaining (failing, in priority order)
- Estimated sessions remaining

Display:
```
◆ Manifest Summary
  Total Features:  [N]
  Passing:         [X] ([percentage]%)
  Failing:         [Y] — [estimated sessions] sessions estimated
  Dependencies:    [Z] features have unresolved dependencies
```

### Step 4: Read LOOP-STATE.json — Check Previous State

Check for previous loop state:

| Previous Status | Action |
|----------------|--------|
| `"ready"` | Fresh start — proceed normally |
| `"running"` | Loop was interrupted — offer to resume from last position |
| `"stopping"` | Graceful stop was requested — ask if user wants to restart |
| `"stopped"` | Clean stop — proceed normally |
| `"escalated"` | Previous escalation — show escalation report, ask to resolve or skip |

If resuming from interruption:
```
◆ Previous Loop Interrupted
  Last feature: F-XXX — [description]
  Session: [N]
  Status at interruption: [status]

  Resume from F-XXX or start fresh? (resume/fresh)
```

### Step 5: Present Execution Plan

Display the ordered list of features to implement:

```
◆ Execution Plan

  Order | Feature | Description                    | Est. Sessions | Dependencies
  ──────┼─────────┼────────────────────────────────┼───────────────┼─────────────
  1     | F-001   | [description]                  | 1             | —
  2     | F-003   | [description]                  | 2             | F-001
  3     | F-002   | [description]                  | 1             | —
  ...

  Total estimated sessions: [N]
  Escalation threshold: 3 consecutive failures on same feature
```

If `--dry-run`: display plan and stop.

### Step 6: Confirm

Ask for confirmation:
```
Start autonomous loop with [N] features ([M] estimated sessions)?
  [Options applied: --from F-XXX, --max-sessions 10, etc.]

  Proceed? (y/n)
```

If no: exit gracefully.

### Step 7: Update LOOP-STATE.json

Set LOOP-STATE.json:

```json
{
  "status": "running",
  "session": [previous + 1],
  "current_feature": "[first feature ID]",
  "started_at": "[ISO 8601 timestamp]",
  "updated_at": "[ISO 8601 timestamp]",
  "config": {
    "from": "[feature ID or null]",
    "max_sessions": "[N or null]",
    "budget": "[N or null]",
    "fail_fast": false
  }
}
```

### Step 8: Display Running Instructions

Print (as markdown, NOT in a code block):

---

## ⚡ TITAN — LOOP RUNNING

The autonomous loop is now active.

| Control | Command |
|---------|---------|
| **Check progress** | `/titan:loop-status` |
| **Graceful stop** | `/titan:loop-stop` (finishes current feature) |
| **Force stop** | `/titan:loop-stop --force` (stops immediately) |

**Current target:** F-XXX — [description]

The loop will:
1. Implement the current feature
2. Run E2E verification against acceptance criteria
3. Update MANIFEST.json status
4. Commit changes
5. Advance to next feature or escalate on repeated failure

---

### Step 9: Start the Loop

Begin the autonomous loop. For each feature:

1. Read feature details from MANIFEST.json
2. Load `.titan/prompts/coding-agent.md` for implementation guidance
3. Implement the feature
4. Run `/titan:verify-e2e [feature-id]` to verify
5. If PASS: update status, commit, advance to next feature
6. If FAIL: increment `consecutive_failures`, retry (up to 3 attempts)
7. If 3 consecutive failures: escalate — set status to `"escalated"`, write escalation report, stop loop
8. Update PROGRESS.md after each feature
9. Check for stop signal (LOOP-STATE.json status changed to `"stopping"`)

---

### ★ Recommended

> Monitor progress with `/titan:loop-status`. Stop gracefully with `/titan:loop-stop`.

### Other options

| Command | Action |
|---------|--------|
| `/titan:loop-status` | View loop dashboard and progress |
| `/titan:loop-stop` | Gracefully stop after current feature |
| `/titan:progress` | Full project dashboard |
| `/titan:verify-e2e --passing` | Regression check all passing features |

---

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| LOOP-STATE.json | `.titan/LOOP-STATE.json` | Updated loop state |
| MANIFEST.json | `.titan/MANIFEST.json` | Updated feature statuses |
| PROGRESS.md | `.titan/PROGRESS.md` | Session entries appended |
| Git commits | Git history | One commit per completed feature |

## State Updates

- LOOP-STATE.json status → `"running"`
- LOOP-STATE.json session incremented
- STATE.md step → "loop (running)"
- STATE.md Next Action → "Monitor with /titan:loop-status"

## Error Handling

| Error | Resolution |
|-------|-----------|
| MANIFEST.json parse error | Validate schema, offer to repair |
| Feature dependencies not met | Skip feature, queue after dependencies |
| Environment setup fails | Run `init.sh`, retry once, then escalate |
| 3 consecutive failures on same feature | Escalate — write report, pause loop, suggest manual intervention |
| Cost budget exceeded | Graceful stop with budget report |
| Max sessions reached | Graceful stop with progress summary |

## Tips

- The loop is designed to be interruptible — use `/titan:loop-stop` to pause at a clean point.
- Escalation is not failure — it means the feature needs human judgment. Review the escalation report and either simplify the feature, add context, or resolve the blocker.
- Use `--dry-run` first to review the execution plan before committing to a long loop.
- The `--from` flag is useful after resolving an escalation — resume from the feature that was stuck.
- Keep `init.sh` updated — the loop runs it at the start of each session to ensure a clean environment.

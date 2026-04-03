---
name: titan:loop-stop
description: Gracefully stop the autonomous loop after current feature completes
---

# /titan:loop-stop — Stop Autonomous Loop

> Use this command to gracefully stop the autonomous development loop. By default, the loop finishes the current feature before stopping. Use `--force` to stop immediately.

## Prerequisites

- `.titan/LOOP-STATE.json` exists.
- Loop is currently in a running or active state.

If LOOP-STATE.json does not exist:
```
⚠ No LOOP-STATE.json found.
  No loop to stop. Run /titan:03-bootstrap to initialize.
```
And stop.

## Process

### Step 1: Display Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — STOP AUTONOMOUS LOOP                              ║
╚══════════════════════════════════════════════════════════════╝
```

### Step 2: Read LOOP-STATE.json — Verify Loop Status

Read `.titan/LOOP-STATE.json` and check the current status:

| Current Status | Action |
|----------------|--------|
| `"running"` | Proceed with stop |
| `"stopping"` | Already stopping — print: "Loop is already stopping. Waiting for current feature to complete." |
| `"stopped"` | Already stopped — print: "Loop is not running. Use /titan:loop-start to begin." |
| `"ready"` | Never started — print: "Loop has not been started. Use /titan:loop-start to begin." |
| `"escalated"` | Escalated — print: "Loop is escalated (not running). Review the escalation report." |

If the loop is not running, stop here.

### Step 3: Set Stop Signal

**Default (graceful stop):**

Update LOOP-STATE.json:
```json
{
  "status": "stopping",
  "updated_at": "[ISO 8601 timestamp]"
}
```

Print:
```
◆ Graceful stop requested.
  The loop will finish the current feature before stopping.
  Current feature: F-XXX — [description]
```

**With `--force` flag:**

Update LOOP-STATE.json:
```json
{
  "status": "stopped",
  "updated_at": "[ISO 8601 timestamp]"
}
```

Print:
```
◆ Force stop applied.
  The loop has been stopped immediately.
  Current feature F-XXX may be in an incomplete state.
```

### Step 4: Display Current Progress

Read MANIFEST.json and LOOP-STATE.json to compute progress:

```
◆ Loop Progress

  Sessions completed:    [N]
  Features completed:    [X] / [T] ([percentage]%)
  Current feature:       F-XXX — [description]
  Time elapsed:          [duration since started_at]
  Consecutive failures:  [N]
```

### Step 5: Display State Summary

Print (as markdown, NOT in a code block):

---

## ⚡ TITAN — LOOP STOPPING

| Metric | Value |
|--------|-------|
| **Status** | [stopping / stopped] |
| **Features Completed** | [X] / [T] |
| **Current Feature** | F-XXX — [description] |
| **Sessions** | [N] completed |
| **Elapsed** | [duration] |

[If graceful: "The loop will stop after completing F-XXX. Check status with `/titan:loop-status`."]
[If force: "The loop has been stopped. F-XXX may need to be re-verified."]

---

### ★ Recommended

> [If graceful: "Check `/titan:loop-status` to confirm the loop has stopped, then review progress."]
> [If force: "Run `/titan:verify-e2e F-XXX` to check the state of the interrupted feature."]

### Other options

| Command | Action |
|---------|--------|
| `/titan:loop-status` | Check if loop has fully stopped |
| `/titan:loop-start` | Restart the loop later |
| `/titan:verify-e2e --passing` | Regression check completed features |
| `/titan:progress` | Full project dashboard |

---

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| LOOP-STATE.json | `.titan/LOOP-STATE.json` | Updated with stop signal |

## State Updates

- LOOP-STATE.json status → `"stopping"` (graceful) or `"stopped"` (force)
- LOOP-STATE.json updated_at refreshed
- STATE.md Last Action → "Loop stop requested"

## Error Handling

| Error | Resolution |
|-------|-----------|
| LOOP-STATE.json missing | Inform user, suggest `/titan:03-bootstrap` |
| LOOP-STATE.json corrupted | Attempt to reconstruct from PROGRESS.md and MANIFEST.json |
| Loop not running | Inform user of current status, suggest appropriate action |
| Force stop during file write | Git status check — if dirty, offer to commit or stash |

## Tips

- Prefer graceful stop over force stop — it ensures the current feature is in a clean state.
- After stopping, run `/titan:verify-e2e --passing` to confirm no regressions occurred.
- Force stop is safe for the codebase (git protects you), but the current feature may need re-work.
- You can restart the loop anytime with `/titan:loop-start` — it picks up where it left off.

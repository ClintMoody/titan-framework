# Crash Recovery & Session Forensics

> Cannibalized from GSD-2. Protects against session crashes, timeouts, and interruptions
> with lock files, completed unit tracking, and forensic context reconstruction.

## Problem

Claude Code sessions can crash, timeout, or be interrupted. Without crash recovery:
- Completed work may be re-executed (wasting tokens and time)
- Partially completed tasks may leave inconsistent state
- Context is lost with no way to reconstruct what happened

## Solution: Three-Layer Recovery

### Layer 1: Lock Files

During `/titan:06-build`, a lock file is created at `.titan/build.lock`:

```json
{
  "pid": "session-identifier",
  "phase": 3,
  "task": "T2",
  "wave": 1,
  "started": "2026-03-17T10:00:00Z",
  "last_heartbeat": "2026-03-17T10:05:00Z"
}
```

**On session start:**
1. Check for `.titan/build.lock`
2. If found and stale (last_heartbeat > 10 minutes ago): previous session crashed
3. Trigger recovery protocol (see below)
4. If found and recent: another session is running — warn and stop

**During build:**
- Update `last_heartbeat` after each task completes
- Remove lock file when build finishes (normally or via save-state)

**On pause:**
- Remove lock file explicitly in `/titan:pause`

### Layer 2: Completed Units Tracking

File: `.titan/completed-units.json`

```json
{
  "version": 1,
  "units": [
    {
      "phase": 3,
      "task": "T1",
      "commit": "abc123f",
      "completed": "2026-03-17T10:02:00Z"
    },
    {
      "phase": 3,
      "task": "T2",
      "commit": "def456a",
      "completed": "2026-03-17T10:04:00Z"
    }
  ]
}
```

**During build:**
- After each successful task commit, append the unit to completed-units.json
- Before dispatching any task, check if it's already in completed-units.json
- If already completed: skip it (print "✓ T[X] already completed (recovered)")

**On phase complete:**
- Clear units for that phase from completed-units.json

This prevents re-execution of already-committed work after a crash.

### Layer 3: Session Forensics

When a stale lock is detected, TITAN reconstructs context:

1. **Read the lock file** — identifies which phase/task was in progress
2. **Read git log** — identifies which tasks have commits (confirmed complete)
3. **Read STATE.md** — identifies the intended plan
4. **Read PLAN.md** — identifies remaining tasks
5. **Cross-reference** — build a recovery briefing

**Recovery Briefing Format:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚡ TITAN — CRASH RECOVERY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Previous session crashed during Phase [NN], Task [TX]
  Last heartbeat: [timestamp]

  Recovery status:
    ✓ T1: [title] — committed (abc123f)
    ✓ T2: [title] — committed (def456a)
    ◆ T3: [title] — IN PROGRESS when crash occurred
    ○ T4: [title] — not started

  Recovery action:
    Resuming from T3. Any partial work from T3 has been discarded.
    [count] tasks remaining.

  [continue] — Resume build from T3
  [revert]   — Revert T3 partial changes and re-plan
  [inspect]  — Show git diff of any uncommitted changes
```

## Integration Points

### /titan:06-build
- Step 1b (new): Check for stale lock → trigger recovery if found
- After Step 3: Write lock file
- After each task: Update lock heartbeat + append to completed-units
- Step 7: Remove lock file

### /titan:pause
- Step 2b (new): Remove lock file explicitly

### /titan:resume
- Step 2b (new): Check for stale lock → show recovery briefing

## Configuration

In `config.yaml`:

```yaml
crash_recovery:
  lock_file: true
  lock_path: ".titan/build.lock"
  completed_units_file: ".titan/completed-units.json"
  forensics: true
```

Set `lock_file: false` to disable (not recommended).

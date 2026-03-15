---
name: titan:loop-status
description: Show autonomous loop health, progress, and next priority
---

# /titan:loop-status — Loop Status Dashboard

> Use this command to check the health, progress, and state of the autonomous development loop at any time.

## Prerequisites

- `.titan/LOOP-STATE.json` exists.
- `.titan/MANIFEST.json` exists.

If either file is missing:
```
⚠ Loop infrastructure not found.
  Run /titan:00-bootstrap to set up autonomous development.
```
And stop.

## Process

### Step 1: Display Banner

Print this exactly:

```
⚡ TITAN — LOOP STATUS
```

### Step 2: Read LOOP-STATE.json

Load the current loop state. Extract:
- status (running / stopped / stopping / ready / escalated)
- session number
- current feature
- last completed feature
- consecutive failures
- escalation details (if any)
- started_at timestamp
- config (max sessions, budget, etc.)

### Step 3: Read MANIFEST.json — Compute Progress

Load MANIFEST.json and compute:
- Total features
- Features passing
- Features failing
- Completion percentage
- Features remaining by priority
- Estimated sessions remaining

### Step 4: Read PROGRESS.md — Last 3 Sessions

Read `.titan/PROGRESS.md` and extract the last 3 session entries for the recent activity summary.

### Step 5: Display Dashboard

Print (as markdown, NOT in a code block):

---

## ⚡ TITAN — LOOP DASHBOARD

### Status

| Field | Value |
|-------|-------|
| **Loop State** | [running / stopped / stopping / ready / escalated] |
| **Session** | [N] |
| **Started** | [timestamp or "—"] |
| **Elapsed** | [duration or "—"] |
| **Current Feature** | [F-XXX — description or "None"] |

### Progress

```
[X] / [T] features passing ([percentage]%)
▓▓▓▓▓▓▓▓░░░░░░░░ [visual progress bar]
```

| Phase | Features | Passing | Status |
|-------|----------|---------|--------|
| Phase 1 — [name] | [N] | [X]/[N] | [complete / in progress / pending] |
| Phase 2 — [name] | [N] | [X]/[N] | [complete / in progress / pending] |
| ... | | | |

### Recent Activity

| Session | Feature | Result | Duration |
|---------|---------|--------|----------|
| [N] | F-XXX — [desc] | ✓ Pass | [duration] |
| [N-1] | F-XXX — [desc] | ✗ Fail (attempt 2) | [duration] |
| [N-2] | F-XXX — [desc] | ✓ Pass | [duration] |

### Health

| Indicator | Status |
|-----------|--------|
| **Consecutive Failures** | [N] [✓ Healthy / ⚠ Warning (2) / ✗ Escalation threshold (3+)] |
| **Environment** | [✓ init.sh passes / ⚠ Last run had warnings / ✗ Environment broken] |
| **Escalation** | [None / ⚠ Pending — see report below] |

[If escalated, display escalation section:]

### Escalation Report

| Field | Value |
|-------|-------|
| **Feature** | F-XXX — [description] |
| **Attempts** | [N] |
| **Last Error** | [error summary] |
| **Recommended Action** | [suggestion] |

**Failure History:**
1. Attempt 1: [what was tried, why it failed]
2. Attempt 2: [what was tried, why it failed]
3. Attempt 3: [what was tried, why it failed]

**Suggested Resolutions:**
- [Simplify the feature's acceptance criteria]
- [Add missing dependency or infrastructure]
- [Break the feature into smaller sub-features]
- [Provide additional context in MANIFEST.json]

---

### Step 6: Estimated Time Remaining

Calculate and display:
```
◆ Estimate
  Features remaining:     [N]
  Avg sessions/feature:   [calculated from history]
  Estimated sessions:     [N]
  Estimated completion:   [rough time estimate based on session frequency]
```

If no history yet:
```
◆ Estimate
  Features remaining:     [N]
  Estimated sessions:     [sum of estimated_sessions from MANIFEST]
  (Estimates will improve after the first few features complete.)
```

### Step 7: Context-Aware Next Action

Display based on current status (as markdown, NOT in a code block):

---

**If running:**

> Loop is progressing normally. Check back later or run `/titan:loop-stop` to pause.

**If escalated:**

### ★ Recommended

> Review the escalation report above and resolve the blocker. Then run `/titan:loop-start --from F-XXX` to resume.

### Other options

| Command | Action |
|---------|--------|
| `/titan:debug` | Debug the failing feature |
| `/titan:verify-e2e F-XXX` | Re-verify the escalated feature |
| `/titan:loop-start --from F-XXX` | Resume from the stuck feature |

**If stopped:**

### ★ Recommended

> Run `/titan:loop-start` to resume autonomous development.

### Other options

| Command | Action |
|---------|--------|
| `/titan:loop-start` | Resume the loop |
| `/titan:verify-e2e --passing` | Regression check before resuming |
| `/titan:progress` | Full project dashboard |

**If ready (never started):**

### ★ Recommended

> Run `/titan:loop-start` to begin autonomous development.

**If stopping:**

> Loop is finishing the current feature. Run `/titan:loop-status` again in a moment to confirm it has stopped.

---

## Outputs

No artifacts created. This is a read-only status command.

## State Updates

None — this command only reads state, it does not modify it.

## Error Handling

| Error | Resolution |
|-------|-----------|
| LOOP-STATE.json missing | Direct to `/titan:00-bootstrap` |
| MANIFEST.json missing | Direct to `/titan:00-bootstrap` |
| LOOP-STATE.json corrupted | Attempt to reconstruct from PROGRESS.md |
| PROGRESS.md missing | Show status without recent activity section |
| Inconsistent state (LOOP-STATE says running but no process active) | Suggest `/titan:loop-stop --force` then `/titan:loop-start` |

## Tips

- Run `/titan:loop-status` anytime — it's read-only and safe.
- The health indicators help you spot problems before they escalate.
- If the consecutive failure count is climbing, consider stopping the loop and debugging manually.
- The estimated completion improves over time as the loop builds a history of session durations.
- Escalation reports are designed to be actionable — follow the suggested resolutions.

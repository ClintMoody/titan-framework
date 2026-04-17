---
name: titan:autopilot
description: Supervised autonomous mode — plan-build-verify with human checkpoints between phases
---

# /titan:autopilot — Supervised Autonomous Mode

> Run plan-build-verify for each remaining phase. Pauses between phases for user confirmation. Stops gracefully on context pressure or rate limits.

## Prerequisites

- `.titan/` directory exists with `STATE.md` and `config.yaml`.
- At least one phase is defined in ROADMAP.md.
- The project has completed vision (PROJECT.md exists).

## Process

### Step 1: Display Autopilot Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — SUPERVISED AUTONOMOUS MODE                       ║
╚══════════════════════════════════════════════════════════════╝

  Runs plan → build → verify for each remaining phase.
  Pauses between phases for your review.
```

### Step 2: Determine Scope

Read STATE.md and ROADMAP.md to determine what needs to be run.

Present the execution plan to the user:

```
◆ Autopilot Execution Plan

  Starting from: Phase [NN] — [name] ([plan|build|verify] step)
  Phases to run:
    [NN] [name] — [plan → build → verify]
    [NN+1] [name] — [plan → build → verify]
    ...

  Estimated steps: [count]
  Mode: Supervised (pauses between phases)

  Proceed? (y/n)
```

Wait for explicit user confirmation. Do NOT proceed without it.

### Step 3: Execute Phase Loop

For each remaining phase, run the plan-build-verify cycle:

1. **Plan**: Execute `/titan:06-plan` for the current phase (skip if PLAN.md already exists and is approved).
2. **Build**: Execute `/titan:07-build` for the current phase. Wave reconciliation (v2.3) runs after every wave.
3. **Verify**: Execute `/titan:08-verify` for the current phase. If verification fails with critical findings, stop and report.

### Step 4: Between-Phase Checkpoint

After each phase completes verification, pause and present a summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ★ Phase [NN] Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Tasks completed: [N]
  Commits: [N]
  Verification: PASS / PASS-WITH-NOTES
  Findings: [N] minor, [N] important, 0 critical

  Next phase: Phase [NN+1] — [name]

  Continue to next phase? (y/n)
```

Wait for user confirmation before proceeding to the next phase. This is the supervised checkpoint — the user reviews what was built before authorizing the next phase.

### Step 5: Context Management

Monitor context usage throughout execution. When context usage exceeds 60%:

1. Commit all current work
2. Update `.titan/progress.log` with current state
3. Tell the user:
   ```
   ⚠ Context at 60%. Recommend fresh session.
     All work has been committed. Progress log updated.
     Run /titan:autopilot to continue from where we left off.
   ```
4. Stop gracefully. Do NOT attempt to continue or spawn successors.

### Step 6: Rate Limit Handling

If any API call returns a rate limit error:

1. Commit all completed work
2. Update `.titan/progress.log` with current state
3. Tell the user:
   ```
   ⚠ Rate limited. All work committed. Progress log updated.
     Wait a few minutes, then run /titan:autopilot to continue.
   ```
4. Stop gracefully.

### Step 7: Completion

When all phases in the execution plan are complete:

Print (as markdown, NOT in a code block):

---

## ✓ TITAN — AUTOPILOT COMPLETE

| Metric | Value |
|--------|-------|
| **Phases completed** | [list] |
| **Total tasks** | [count] |
| **Total commits** | [count] |
| **Verification** | All passed |

---

### ★ Recommended

> Run `/titan:09-ship` to **release the milestone**. All phases are built and verified.

### Other options

| Command | Action |
|---------|--------|
| `/titan:audit` | Run a comprehensive audit before shipping |
| `/titan:progress` | See full project dashboard |
| `/titan:autopilot-full` | Switch to full autonomous mode (no human checkpoints) |

---

## Safety Rules

1. **Always confirm before starting.** Never auto-execute without explicit user approval.
2. **Pause between phases.** The user must approve each phase transition.
3. **Stop on errors.** Build failures, verification failures — all halt autopilot.
4. **Fresh context per step.** Use agent spawning to ensure each step gets clean context.
5. **Never force through failures.** If a task fails, the user decides: fix, skip, or stop.
6. **Mandatory verification.** Never skip the verify step.
7. **Context at 60% = stop.** Commit, log, tell the user. Do not push further.

## Outputs

All outputs from the individual commands are produced (PLAN.md, commits, SUMMARY.md, EVALUATION.md, etc.).

## State Updates

- STATE.md updated after each phase transition.
- PLAN.md updated after each task completion.
- `.titan/progress.log` updated after each task.
- KNOWLEDGE.md updated after each verification.

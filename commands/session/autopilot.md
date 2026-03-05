---
name: titan:autopilot
description: Auto-run the plan-build-verify loop with fresh context per step — supervised automation
---

# /titan:autopilot — Supervised Phase Automation

> Run this command to automatically execute the plan → build → verify cycle for one or more phases with minimal manual intervention. The system pauses at decision points and stops on errors.

## Prerequisites

- `.titan/` directory exists with `STATE.md` and `config.yaml`.
- At least one phase is defined in ROADMAP.md.
- The project has completed vision (PROJECT.md exists).

## Process

### Step 1: Display Autopilot Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — AUTOPILOT MODE                                   ║
╚══════════════════════════════════════════════════════════════╝

  Supervised automation of the plan → build → verify cycle.
  Will pause at decision points and stop on errors.
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
  Pause points: decision checkpoints, human-verify tasks
  Stop conditions: any error, verification failure, blocker

  Proceed? (y/n)
```

Wait for explicit user confirmation. Do NOT proceed without it.

### Step 3: Execute Phase Loop

For each phase in the execution plan, run the three-step cycle:

#### Step 3a: Plan Phase

1. Print status:
```
───────────────────────────────────────────────────
⚡ AUTOPILOT: Phase [NN] — Planning
───────────────────────────────────────────────────
```

2. Check if PLAN.md already exists for this phase.
   - If exists and has incomplete tasks: skip planning, move to build.
   - If exists and all tasks complete: skip to verify.
   - If not exists: execute planning.

3. Execute planning:
   - Spawn titan-researcher agent to analyze the codebase for the phase's scope.
   - Generate PLAN.md with tasks, acceptance criteria, file boundaries, and wave structure.
   - Use fresh context for the research (this is critical — `/clear` equivalent).

4. Present the generated plan summary:
```
  Plan generated for Phase [NN]:
    Tasks: [count]
    Waves: [count]
    Estimated complexity: [low|medium|high]
```

5. **CHECKPOINT — Decision Point:** If any tasks are marked `human-verify` or if the plan requires architectural decisions not already in DECISIONS.md:
```
⚠ AUTOPILOT PAUSED — Decision Required
  [Description of what needs human input]
  Continue after resolving? (y/n)
```

#### Step 3b: Build Phase

1. Print status:
```
───────────────────────────────────────────────────
⚡ AUTOPILOT: Phase [NN] — Building
───────────────────────────────────────────────────
```

2. Execute tasks from PLAN.md in wave order:
   - For each wave, process tasks according to their type:
     - `agent` tasks: spawn titan-executor with fresh context.
     - `in-session` tasks: execute directly (simple changes).
   - After each task:
     - Update PLAN.md task status.
     - Create atomic commit: `titan(phase-NN): [task description]`
     - Print: `✓ Task [N]/[total]: [description]`

3. **ERROR HANDLING:** If any task fails:
```
✗ AUTOPILOT STOPPED — Build Error
  Task: [task description]
  Error: [error description]

  Options:
    1. Fix the issue and type "continue" to resume autopilot
    2. Type "skip" to skip this task and continue
    3. Type "stop" to exit autopilot mode

  What would you like to do?
```
   - Never force through failures.
   - Never skip without explicit user instruction.

4. After all tasks complete:
```
  Build complete for Phase [NN]:
    ✓ [count] tasks completed
    ✓ [count] commits created
```

#### Step 3c: Verify Phase

1. Print status:
```
───────────────────────────────────────────────────
⚡ AUTOPILOT: Phase [NN] — Verifying
───────────────────────────────────────────────────
```

2. Execute verification with fresh context:
   - Spawn titan-verifier agent for adversarial review.
   - Run reconciliation: compare PLAN.md tasks/ACs against actual implementation.
   - Capture knowledge: extract learnings for KNOWLEDGE.md.

3. **If verification passes** (no critical findings):
```
  ✓ Phase [NN] verified.
    Findings: [N] minor, [N] important, 0 critical
    Knowledge: [N] new entries captured
```
   - Update STATE.md: mark phase complete.
   - Continue to next phase.

4. **If verification fails** (critical findings):
```
✗ AUTOPILOT STOPPED — Verification Failed

  Critical Findings:
    1. [finding description]
    2. [finding description]

  These issues must be resolved before continuing.
  Fix the issues and type "continue" to re-verify,
  or type "stop" to exit autopilot mode.
```
   - Do NOT continue to the next phase.
   - Wait for user to fix issues and confirm.

### Step 4: Phase Transition

Between phases:

```
───────────────────────────────────────────────────
★ Phase [NN] Complete — Moving to Phase [NN+1]
───────────────────────────────────────────────────
```

Update STATE.md with new current phase.

### Step 5: Completion

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

## Safety Rules

1. **Always confirm before starting.** Never auto-execute without explicit user approval.
2. **Stop on ANY error.** Build failures, test failures, verification failures — all halt autopilot.
3. **Pause at decision points.** Any task requiring architectural decisions, human review, or subjective judgment pauses for user input.
4. **Fresh context per step.** Use `/clear` or agent spawning to ensure each step gets clean context. Never let context accumulation degrade quality.
5. **Never force through failures.** If a task fails, the user decides: fix, skip, or stop.
6. **Atomic commits.** Every task gets its own commit. No batching.
7. **Mandatory verification.** Never skip the verify step, even if the user asks. Verification is a core TITAN principle.

## Outputs

All outputs from the individual commands are produced (PLAN.md, commits, SUMMARY.md, EVALUATION.md, etc.).

## State Updates

- STATE.md updated after each phase transition.
- PLAN.md updated after each task completion.
- DECISIONS.md updated if new decisions are made during execution.
- KNOWLEDGE.md updated after each verification.

## Error Handling

| Error | Resolution |
|-------|-----------|
| No phases defined | Direct user to `/titan:02-vision` to create ROADMAP.md |
| Context running low mid-phase | Pause autopilot, create handoff, suggest `/titan:pause` then resume |
| Git conflicts | Stop autopilot, present conflicts to user |
| Agent spawn failure | Retry once, then fall back to in-session execution |
| User cancels mid-run | Save current state, update STATE.md, exit cleanly |

## What's Next

After autopilot completes all phases, display (as markdown, NOT in a code block):

---

### ★ Recommended

> Run `/titan:08-ship` to **release the milestone**. All phases are built and verified.

### Other options

| Command | Action |
|---------|--------|
| `/titan:audit` | Run a comprehensive audit before shipping |
| `/titan:progress` | See full project dashboard |
| `/titan:review` | Do a final manual review of the entire codebase |
| `/titan:pause` | Save state and take a break before shipping |

---

If autopilot was stopped mid-run, display (as markdown, NOT in a code block):

---

### ★ Recommended

> **Fix the issue, then run `/titan:autopilot` to continue.** Autopilot will pick up from Phase NN, Task TN.

### Other options

| Command | Action |
|---------|--------|
| `/titan:06-build` | Continue building manually (more control) |
| `/titan:debug` | Debug the issue that stopped autopilot |
| `/titan:progress` | See what was completed vs. what remains |
| `/titan:pause` | Save state and come back later |

---

## Tips

- Autopilot works best for well-defined phases with clear acceptance criteria.
- For exploratory or research-heavy phases, manual execution gives better results.
- You can start autopilot mid-phase — it picks up where the current PLAN.md left off.
- If you're unsure about a phase, run `/titan:05-plan` manually first, review it, then start autopilot from the build step.

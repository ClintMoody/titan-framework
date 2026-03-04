---
name: titan:06-build
description: Execute the phase plan using parallel agents and in-session work. Thin orchestrator pattern — delegate, don't implement.
---

# /titan:build — Phase Execution

> Execute the approved PLAN.md for the current phase. This command uses the Thin Orchestrator
> Pattern: it stays at 10-15% context usage by delegating implementation to fresh-context
> titan-executor agents. The orchestrator dispatches, monitors, and commits — it does NOT
> write production code itself (except for in-session integration tasks).

## Prerequisites

Before running, verify ALL of the following. If any are missing, STOP and tell the user.

- `.titan/STATE.md` exists and shows step is `build` or `build (ready)`
- An approved PLAN.md exists for the current phase (`.titan/phases/NN-phase-name/PLAN.md`)
- PLAN.md frontmatter `status` is `approved` (not `draft`)
- Git working tree is clean (no uncommitted changes). If dirty, ask user to commit or stash first.

If STATE.md shows step is `verify`, warn: "Phase NN is already built. Run `/titan:verify` to verify it."

---

## Process

### Step 1 — Display Banner and Load Plan

Print:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — BUILD                                           ║
╚══════════════════════════════════════════════════════════════╝
Phase N of M ▓▓▓▓▓▓▓▓░░░░░░░░ XX%
```

Read PLAN.md. Extract:
- Phase number, name, goal
- Task list (with all fields)
- Wave structure
- Boundaries
- Checkpoints
- Git branch name from frontmatter

Print orientation:
```
◆ Phase: NN — [Phase Name]
◆ Goal: [goal]
◆ Tasks: [count] ([agent count] agent, [in-session count] in-session)
◆ Waves: [count]
◆ Branch: titan/phase-NN-phase-name
◆ Boundaries: [count] protected paths
```

### Step 2 — Create Git Branch

Check if the branch already exists:
- If it exists AND has commits: ask "Branch `titan/phase-NN-name` already has work. Continue from where it left off? [yes/no]"
- If it exists but is empty: switch to it silently.
- If it does not exist: create it from the current HEAD.

```bash
git checkout -b titan/phase-NN-phase-name
```

If branch creation fails (e.g., uncommitted changes), report the error and stop.

### Step 3 — Initialize Progress Tracker

Create an in-memory task status tracker:

```
Task T1: ○ PENDING
Task T2: ○ PENDING
Task T3: ○ PENDING
...
```

Track these states per task: `PENDING` | `IN_PROGRESS` | `DONE` | `FAILED` | `BLOCKED`

### Step 4 — Execute Waves

Process waves in strict order. Within each wave, run agent-mode tasks in parallel and in-session tasks sequentially.

#### For Each Wave:

Print:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Wave [N] — [wave description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**A) Check Dependencies:**
Before starting any task in this wave, confirm all dependency tasks from prior waves are `DONE`. If any dependency is `FAILED` or `BLOCKED`:
- Mark the dependent task as `BLOCKED`
- Print: `⚠ Task T[X] BLOCKED — dependency T[Y] is [FAILED|BLOCKED]`
- Continue with other tasks in the wave that are not blocked

**B) Dispatch Agent-Mode Tasks (parallel):**

For each `agent` mode task in this wave, spawn a titan-executor subagent with this brief:

```
AGENT: titan-executor
TASK ID: T[number]
TASK: [task title]

PHASE CONTEXT:
- Phase: NN — [Phase Name]
- Goal: [phase goal]

WHAT TO IMPLEMENT:
[Full action description from PLAN.md]

FILES TO MODIFY: [list from plan]
FILES TO CREATE: [list from plan]
FILES TO READ (reference only, do NOT modify): [list from plan]

BOUNDARIES — DO NOT TOUCH THESE FILES:
[Full boundaries list from PLAN.md]

EXISTING PATTERNS AND CONVENTIONS:
[Key patterns from ARCHITECTURE.md or researcher findings — keep brief, 5-10 lines max]

DOMAIN: [domain from config.yaml, if set]
DOMAIN RULES: [relevant domain plugin rules, if any]

VERIFICATION STEPS (you must confirm all pass before reporting done):
[verification steps from plan]

DONE CRITERIA:
[done criteria from plan]

RULES:
1. Implement EXACTLY what is specified. Do not add features, refactors, or "improvements" not in the spec.
2. Follow existing code patterns and conventions. Match the style of surrounding code.
3. Do NOT modify any file not listed in "Files to Modify" or "Files to Create."
4. Do NOT modify any file listed in Boundaries.
5. Run all verification steps. Report results.
6. If you encounter a blocker (missing dependency, unclear spec, conflicting code), STOP and report it. Do NOT guess.
7. Keep your changes minimal and focused. One task = one logical change.

OUTPUT CONTRACT:
Return a structured report:
- STATUS: DONE | BLOCKED
- FILES_MODIFIED: [list of files actually modified]
- FILES_CREATED: [list of files actually created]
- VERIFICATION_RESULTS: [pass/fail for each verification step]
- NOTES: [anything the orchestrator should know]
- BLOCKER: [if BLOCKED, describe what's blocking]
```

**C) Wait for Agent Results:**

As each agent completes, process its result:

1. **If STATUS is DONE:**
   - Verify the agent respected boundaries (check git diff for boundary violations)
   - If boundaries violated: REJECT the work, revert changes, re-dispatch with stronger boundary emphasis
   - If boundaries clean: stage the changes and create an atomic commit:
     ```
     git add [specific files from agent report]
     git commit -m "titan(phase-NN): T[X] — [task title]"
     ```
   - Update task status to `DONE`
   - Print: `✓ Task T[X]: [task title] — DONE`

2. **If STATUS is BLOCKED:**
   - Print: `⚠ Task T[X]: [task title] — BLOCKED: [blocker description]`
   - Attempt ONE retry with additional context (e.g., read the blocking file and include its contents)
   - If retry also blocks: mark task as `BLOCKED`, record blocker details
   - Print: `✗ Task T[X]: [task title] — BLOCKED after retry. Moving on.`

**D) Execute In-Session Tasks (sequential):**

For `in-session` mode tasks in this wave, execute them directly in the current session:

1. Print: `◆ Task T[X]: [task title] — Starting (in-session)`
2. Read the necessary files
3. Implement the changes as specified in the plan
4. Run verification steps
5. If all checks pass:
   - Stage and commit: `git add [files] && git commit -m "titan(phase-NN): T[X] — [task title]"`
   - Mark as `DONE`
   - Print: `✓ Task T[X]: [task title] — DONE`
6. If checks fail:
   - Print what failed
   - Attempt to fix (one attempt)
   - If fix succeeds, commit and mark DONE
   - If fix fails, mark BLOCKED

**E) Wave Checkpoint:**

After all tasks in a wave complete (or are blocked), check if a checkpoint is defined for this point.

If `human-verify` checkpoint:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚡ CHECKPOINT — Wave [N] Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Completed: [list of DONE tasks]
Blocked:   [list of BLOCKED tasks, if any]

Please review the changes. Options:
  [continue]  — Proceed to Wave [N+1]
  [review]    — Show me the git diff for this wave
  [fix]       — I see an issue, let me describe it
  [abort]     — Stop the build (state will be saved)
```

If `decision` checkpoint: present the decision, options, and trade-offs. Wait for user choice.
If `human-action` checkpoint: describe what the user needs to do. Wait for confirmation.

### Step 5 — Context Monitoring

After each task completion, evaluate context usage. Use this heuristic:
- Count the approximate tokens consumed so far in this session
- Map to context brackets: FRESH (>70%), MODERATE (40-70%), DEEP (20-40%), CRITICAL (<20%)

Behavior per bracket:
- **FRESH / MODERATE**: Continue normally.
- **DEEP**: Print warning:
  ```
  ⚠ Context bracket: DEEP (est. ~[XX]% remaining)
  Remaining tasks: [count]. Consider saving state if more than 2 tasks remain.
  Options: [continue] [save-and-resume]
  ```
- **CRITICAL**: STOP immediately.
  ```
  ⚠ Context bracket: CRITICAL — Saving state now.
  ```
  Execute the state save procedure (Step 7) and instruct the user to resume with `/titan:resume` then `/titan:build`.

### Step 6 — Build Complete (All Waves Done)

After all waves execute, print the final summary:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — BUILD COMPLETE                                  ║
╚══════════════════════════════════════════════════════════════╝

Phase NN — [Phase Name]
Branch: titan/phase-NN-phase-name

Task Summary:
  ✓ T1: [title]                          DONE
  ✓ T2: [title]                          DONE
  ✗ T3: [title]                          BLOCKED — [reason]

Commits: [count] atomic commits created
Result: [count DONE] of [total] tasks completed

[If all DONE:]
✓ All tasks complete. Run /titan:verify to verify this phase.

[If any BLOCKED:]
⚠ [count] tasks blocked. Review blockers above.
Options:
  [verify]  — Proceed to verification with completed tasks
  [retry]   — Retry blocked tasks with additional context
  [replan]  — Return to /titan:plan to restructure
```

### Step 7 — Update State

Update STATE.md regardless of outcome:

**If all tasks DONE:**
```markdown
## Current Position
- Phase: NN
- Step: verify (ready)
- Status: active
- Last Action: Build complete — all [count] tasks done for Phase NN
- Updated: [ISO timestamp]

## Next Action
> Run /titan:verify to verify Phase NN — [Phase Name]
```

**If some tasks BLOCKED:**
```markdown
## Current Position
- Phase: NN
- Step: build (partial)
- Status: blocked
- Last Action: Build partial — [done count] of [total] tasks done, [blocked count] blocked
- Updated: [ISO timestamp]

## Blockers
| Blocker | Impact | Proposed Resolution |
|---------|--------|-------------------|
| T[X]: [blocker description] | [which dependent tasks are affected] | [suggested fix] |

## Next Action
> Resolve blockers and re-run /titan:build, or run /titan:verify with partial completion
```

**If context save triggered:**
```markdown
## Current Position
- Phase: NN
- Step: build (in-progress)
- Status: paused
- Last Action: Context save — [done count] of [total] tasks done, [remaining] remaining
- Updated: [ISO timestamp]

## Next Action
> Run /titan:resume then /titan:build to continue Phase NN
```

Update PLAN.md frontmatter `status` to `built` (or `partial` if blockers).

---

## Outputs

| Artifact | Location | Description |
|----------|----------|-------------|
| Git commits | `titan/phase-NN-phase-name` branch | One atomic commit per completed task |
| STATE.md | `.titan/STATE.md` | Updated with build results |
| PLAN.md | `.titan/phases/NN-phase-name/PLAN.md` | Status updated in frontmatter |

---

## Critical Rules — Thin Orchestrator Pattern

These rules are NON-NEGOTIABLE. Violating them defeats the purpose of the agent architecture.

1. **DO NOT write production code in the orchestrator session.** Delegate to titan-executor agents. The only exception is `in-session` tasks explicitly marked in the plan.
2. **DO NOT read large files into the orchestrator context.** Pass file paths to agents. Let agents read what they need.
3. **DO NOT improvise.** Execute the plan literally. If the plan is wrong, go back to `/titan:plan`.
4. **DO NOT combine tasks into single commits.** One task = one commit. This is non-negotiable for `git bisect` and reconciliation.
5. **DO NOT modify files listed in Boundaries.** Not even "small fixes." Not even comments. Nothing.
6. **Monitor your context usage.** If you feel yourself approaching DEEP bracket, save state proactively.

---

## Error Handling

| Situation | Response |
|-----------|----------|
| Git branch already exists with work | Ask user: continue from existing, or reset branch |
| Agent times out | Mark task BLOCKED with "agent timeout". Suggest retry or in-session fallback. |
| Agent violates boundaries | Revert changes (`git checkout -- [files]`), re-dispatch with explicit boundary warning |
| Git commit fails | Check for hooks, conflicts, or lock files. Report to user. |
| All tasks blocked | Update STATE.md with all blockers. Suggest re-planning. |
| User aborts mid-wave | Save state immediately. Record which tasks are DONE vs PENDING. |
| Merge conflict on branch | Report conflict details. Ask user to resolve manually or suggest resolution. |

---

## Tips

- Trust the thin orchestrator pattern. The urge to "just do it myself" is strong, but fresh-context agents produce better code because they aren't fatigued.
- If a task keeps blocking, it usually means the plan was underspecified. Go back to `/titan:plan` and add more detail.
- Watch context consumption. Building is the most context-hungry phase. Save early, save often.
- Review agent output at checkpoints. Catching issues between waves is much cheaper than catching them in verification.
- The atomic commit history is your safety net. If anything goes wrong, you can revert individual tasks cleanly.

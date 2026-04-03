---
name: titan:quick
description: Small task with full quality guarantees -- no shortcuts
---

# /titan:quick -- Small Task, Full Quality

> Use this command for tasks that do not warrant a full phase cycle (plan/build/verify) but
> still deserve TITAN-level rigor. Bug fixes, small features, config changes, documentation
> updates, dependency bumps -- anything that takes 5-30 minutes but should be done right.
> Creates a mini-plan, executes, reconciles, and commits -- all in one command.

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` first)
- STATE.md is accessible and writable
- Git working tree is clean (no uncommitted changes). If dirty, warn the user and ask whether to stash or abort.

## Process

### Step 1: Display Banner and Capture Task

```
+==============================================================+
|  ++ TITAN -- QUICK TASK                                      |
+==============================================================+
```

Read `.titan/STATE.md` to determine the current phase number and quick task counter.

The user provides the task as the command argument or in a follow-up message. Examples:

- `/titan:quick Fix the login button not responding on mobile`
- `/titan:quick Update axios to v1.7.0`
- `/titan:quick Add loading spinner to the dashboard`

If no task is provided, ask:

> "What's the task? Describe it in one sentence."

### Step 2: Assign Quick Task ID

Quick tasks use a 3-digit sequential counter: `001`, `002`, `003`, etc.

Read `.titan/quick/` directory to find the highest existing ID. Increment by 1.

If the current phase is active (e.g., phase 3), the quick task can optionally use a decimal phase
number (e.g., `3.1`) for interrupt work. Ask the user ONLY if a phase is currently in progress:

> "This will be recorded as quick task #[NNN]. Since phase [N] is active, should this be
> tracked as phase [N.1] instead? (y/N)"

Default: standard quick task numbering. Only use decimal phases if the user explicitly requests it.

Generate a URL-safe slug from the task description (lowercase, hyphens, max 40 chars).

### Step 3: Create Quick Task Directory

```
.titan/quick/NNN-slug/
  TASK.md
```

### Step 4: Write the Mini-Plan (TASK.md)

This is the core of `/titan:quick` -- a compressed version of the full plan/build/verify cycle.

```markdown
# Quick Task #NNN: [task description]

## Task
[One-sentence description of what needs to be done]

## Context
- Phase: [current phase or "standalone"]
- Domain: [from config.yaml]
- Date: [ISO date]

## Acceptance Criteria
Given [precondition]
When [action]
Then [expected result]

[Write 1-3 acceptance criteria. Keep them tight and testable.]

## Scope
### In Scope
- [Specific files/functions/components to touch]

### Out of Scope
- [What this task explicitly does NOT include]

## Plan
1. [Step 1 -- specific action]
2. [Step 2 -- specific action]
3. [Step 3 -- specific action]
[Maximum 5 steps. If more are needed, this is not a quick task -- suggest /titan:06-plan instead.]

## Risk Check
- [ ] Could this break existing tests?
- [ ] Could this affect other features?
- [ ] Does this touch shared/core code?

[If any risk is high, warn the user and suggest running /titan:test or /titan:review after.]
```

Present the mini-plan to the user. Ask:

> "Plan looks good? I'll execute now. (Y/n)"

If the user wants changes, revise. If the user approves (or provides no objection), proceed.

### Step 5: Execute the Plan

Execute each step from the plan sequentially. For each step:

1. State what you are about to do
2. Do it
3. Confirm it is done

Follow all conventions from `.titan/research/conventions.md` if it exists. Follow the domain
plugin checks from `.titan/config.yaml`.

After all steps are complete, run any existing test suites that cover the modified files:

- If tests pass: continue
- If tests fail: stop, report the failure, and ask the user how to proceed (fix or revert)

### Step 6: Reconcile

Update TASK.md with the execution results:

```markdown
## Execution Results

### Steps Completed
1. [x] [Step 1] -- [what actually happened]
2. [x] [Step 2] -- [what actually happened]
3. [x] [Step 3] -- [what actually happened]

### Acceptance Criteria
- [x] AC1: [PASS/FAIL with evidence]
- [x] AC2: [PASS/FAIL with evidence]

### Files Modified
| File | Change Type | Lines Changed |
|------|------------|---------------|

### Deviations from Plan
[Any differences between planned and actual, with explanation. "None" if exact match.]

### Tests
- Existing tests: [PASS/FAIL/NONE]
- New tests added: [yes/no -- list if yes]
```

### Step 7: Quick Review

Perform a rapid self-review of all changes. Check for:

- [ ] No debug/console.log statements left behind
- [ ] No commented-out code added
- [ ] Naming follows project conventions
- [ ] No hardcoded values that should be configurable
- [ ] Error handling is present where needed
- [ ] No unintended side effects on other code

If any issue is found, fix it before committing. Note the fix in the reconciliation.

### Step 8: Commit

Create an atomic git commit:

```
titan(quick-NNN): [task description]
```

If using a decimal phase:

```
titan(phase-NN.N): [task description]
```

The commit message body should include:

```
Quick task #NNN

- [bullet summary of changes]

ACs: all passing
```

### Step 9: Update State and Report

Update `.titan/STATE.md`:

```
- Last Action: Quick task #NNN completed -- [slug]
```

If relevant, add a knowledge entry to `.titan/KNOWLEDGE.md`.

Print (as markdown, NOT in a code block):

---

## ✓ TITAN — QUICK TASK COMPLETE

| Detail | Value |
|--------|-------|
| **Task** | #NNN [description] |
| **Status** | COMPLETE |
| **Files** | [count] modified |
| **Tests** | [PASS/FAIL/NONE] |
| **Commit** | `[short hash]` titan(quick-NNN): [description] |

> All acceptance criteria passing.

---

## Outputs

| File | Content |
|------|---------|
| `.titan/quick/NNN-slug/TASK.md` | Mini-plan with execution results |
| Git commit | `titan(quick-NNN): [description]` |

## State Updates

- `STATE.md` Last Action updated
- `KNOWLEDGE.md` updated if learnings emerged
- Quick task counter incremented

## Error Handling

- **Task is too large:** If the plan requires more than 5 steps or would touch more than 10 files, stop and recommend `/titan:06-plan` + `/titan:07-build` instead. Display: "This task is too large for /titan:quick. Suggesting /titan:06-plan instead."
- **Tests fail after execution:** Do NOT commit. Report the failure. Offer to fix or revert.
- **Git working tree dirty:** Warn the user. Offer to `git stash` before proceeding or abort.
- **User rejects plan:** Revise based on feedback. Allow up to 3 revisions before suggesting the user provide a more specific task description.

## Context Bracket Behavior

| Bracket | Adaptation |
|---------|------------|
| FRESH | Full mini-plan with detailed ACs. Include self-review step. |
| MODERATE | Standard mini-plan. Include self-review step. |
| DEEP | Minimal plan (3 steps max). Skip self-review, rely on tests. |
| CRITICAL | Do NOT execute. Save the task description to STATE.md for next session. |

## Scope Guard

`/titan:quick` is strictly for small, contained tasks. Enforce these limits:

- Maximum 5 plan steps
- Maximum 10 files modified
- Maximum 30 minutes estimated effort
- Maximum 3 acceptance criteria

If ANY limit is exceeded, halt and redirect to `/titan:06-plan`.

## What's Next

After the quick task completes, display (as markdown, NOT in a code block):

---

### ★ Recommended

> **Return to your main workflow.**
> [If a phase is active: Continue with `/titan:07-build` for Phase NN.]
> [If no phase is active: Run `/titan:progress` to see where you left off.]

### Other options

| Command | Action |
|---------|--------|
| `/titan:quick` | Run another small task |
| `/titan:test` | Generate tests for the code you just changed |
| `/titan:review` | Review the changes before committing |
| `/titan:progress` | See full project dashboard and current position |

---

## Tips

- Chain quick tasks: `/titan:quick` three times in a row is totally fine for a burst of small fixes.
- Use decimal phases (`3.1`, `3.2`) when doing interrupt work during an active phase. This keeps the phase history clean and traceable.
- Quick tasks still get full reconciliation. This is what separates TITAN from "just editing files."
- If you are not sure whether something is a quick task or a phase, err on the side of a phase. Phases have better error recovery.

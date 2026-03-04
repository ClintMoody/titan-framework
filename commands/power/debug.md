---
name: titan:debug
description: Scientific debugging with persistent hypothesis tracking
---

# /titan:debug -- Scientific Debugging

> Use this command when something is broken and you do not know why. Applies the scientific
> method to debugging: observe, hypothesize, experiment, analyze, conclude. Maintains persistent
> state in `.titan/debug/` so progress survives `/clear` commands and session breaks.
> Integrates with `git bisect` when the bug is a regression.

## Prerequisites

- `.titan/` directory exists (run `/titan:init` first)
- A reproducible (or at least describable) bug, error, or unexpected behavior
- STATE.md is accessible and writable

## Process

### Step 1: Display Banner and Initialize Session

```
+==============================================================+
|  ++ TITAN -- SCIENTIFIC DEBUGGING                            |
+==============================================================+
```

Check if an existing debug session is in progress by reading `.titan/debug/`:

- **If active session exists:** Ask the user: "Resume debug session `[session-name]`? (Y/n)"
  If yes, skip to Step 3 (pick up where you left off). If no, archive the old session and start fresh.
- **If no active session:** Proceed to create a new one.

Generate a session ID: `DDD` (3-digit sequential counter) + slug from the bug description.

Create: `.titan/debug/[session-id]/SESSION.md`

### Step 2: Observe -- Capture the Symptoms

Ask the user to describe the bug. Gather ALL of the following (ask for any missing pieces):

1. **What is happening?** (exact error message, unexpected behavior, wrong output)
2. **What should be happening?** (expected behavior)
3. **When did it start?** (always been broken, after a recent change, intermittent)
4. **How to reproduce?** (exact steps, commands, inputs)
5. **What has already been tried?** (previous fix attempts)

Record everything in SESSION.md:

```markdown
# Debug Session: [session-id]

## Status: ACTIVE
## Started: [ISO timestamp]
## Bug: [one-line description]

---

## 1. Observations

### Symptoms
[Exact description of the bug]

### Expected Behavior
[What should happen instead]

### Reproduction Steps
1. [step 1]
2. [step 2]
3. [step 3]

### Environment
- OS: [detected]
- Runtime: [detected from project]
- Branch: [current git branch]
- Last known working commit: [if known]

### Error Output
```
[Exact error messages, stack traces, logs]
```

### Prior Attempts
[What the user has already tried and what happened]
```

Reproduce the bug yourself if possible. Confirm the symptoms match the description.

### Step 3: Hypothesize -- Generate Candidate Causes

This is the critical thinking step. Generate a MINIMUM of 2 hypotheses (target 3-5). Each
hypothesis MUST be:

- **Specific** -- names a concrete cause (not "something is wrong with X")
- **Testable** -- can be confirmed or falsified with a specific experiment
- **Distinct** -- each hypothesis proposes a different root cause

Use these strategies to generate hypotheses:

1. **Read the error** -- What does the stack trace or error message literally say?
2. **Trace the data** -- Follow the data from input to the point of failure
3. **Check recent changes** -- `git log` and `git diff` for recent modifications
4. **Examine assumptions** -- What must be true for this code to work? Which assumption might be false?
5. **Consider the environment** -- Dependency versions, config, OS differences, race conditions

Update SESSION.md:

```markdown
## 2. Hypotheses

| # | Hypothesis | Confidence | Status |
|---|-----------|-----------|--------|
| H1 | [specific cause] | [high/medium/low] | UNTESTED |
| H2 | [specific cause] | [high/medium/low] | UNTESTED |
| H3 | [specific cause] | [high/medium/low] | UNTESTED |

### H1: [title]
**Cause:** [detailed explanation of what might be wrong]
**Evidence for:** [what supports this hypothesis]
**Evidence against:** [what contradicts this hypothesis]
**Test plan:** [how to confirm or falsify]

### H2: [title]
...

### H3: [title]
...
```

Present hypotheses to the user. Ask:

> "These are my hypotheses, ordered by confidence. Want to test them in this order, or
> prioritize differently?"

### Step 4: Experiment -- Test Each Hypothesis

For each hypothesis (in priority order):

#### 4a. Design the Experiment

Before touching ANY code, state:

- **Hypothesis being tested:** H[N]
- **What I will do:** [specific action -- add a log, change a value, run with different input]
- **Expected result if hypothesis is correct:** [what we will see]
- **Expected result if hypothesis is wrong:** [what we will see instead]

#### 4b. Execute the Experiment

Run the experiment. Use the LEAST invasive method possible:

1. **Logging/output** -- Add strategic print/log statements to trace execution
2. **Debugger** -- Use language debugger if available (breakpoints, step-through)
3. **Isolation** -- Run the failing code in isolation with controlled inputs
4. **Bisection** -- `git bisect` to find the exact commit that introduced the bug
5. **Minimization** -- Create a minimal reproduction case

IMPORTANT: Track ALL code changes made during debugging. Every added log statement, every
temporary change. These MUST be cleaned up before the fix is committed.

#### 4c. Record Results

Update SESSION.md after EACH experiment:

```markdown
## 3. Experiments

### Experiment E1 (testing H1)
- **Action:** [what was done]
- **Result:** [what happened]
- **Conclusion:** H1 is [CONFIRMED | REFUTED | INCONCLUSIVE]
- **New information:** [anything learned that updates other hypotheses]
```

#### 4d. Iterate

After each experiment:

- **If CONFIRMED:** Proceed to Step 5 (fix the bug)
- **If REFUTED:** Move to the next hypothesis. If all hypotheses exhausted, return to Step 3 with new information and generate new hypotheses.
- **If INCONCLUSIVE:** Design a more targeted experiment for the same hypothesis

### Step 5: Fix -- Apply the Solution

Once the root cause is confirmed:

1. **Describe the fix** before implementing it:

```markdown
## 4. Root Cause
[Precise description of why the bug occurs]

## 5. Fix
**Approach:** [what will be changed and why]
**Files affected:** [list]
**Risk assessment:** [could this fix break anything else?]
```

2. **Implement the fix** -- Make the minimal change that addresses the root cause.

3. **Verify the fix:**
   - Reproduce the original bug -- confirm it no longer occurs
   - Run existing tests -- confirm nothing else broke
   - Test edge cases around the fix

4. **Clean up debugging artifacts:**
   - Remove ALL temporary log statements
   - Remove ALL temporary test code
   - Remove ALL commented-out code added during debugging
   - Verify no debug remnants remain with a targeted grep

### Step 6: Commit and Close

Create an atomic commit:

```
titan(quick-NNN): fix [bug description]

Root cause: [one-line explanation]
Debug session: [session-id]
Hypotheses tested: [N]
```

Update SESSION.md:

```markdown
## Status: RESOLVED
## Resolved: [ISO timestamp]
## Resolution: [one-line summary]
## Commit: [hash]

## 6. Lessons Learned
- [What made this bug hard to find?]
- [What would have prevented this bug?]
- [What should we check for in the future?]
```

Update `.titan/KNOWLEDGE.md` with lessons learned if they are broadly applicable.

Update `.titan/STATE.md`:

```
- Last Action: Debug session [session-id] resolved
```

Display completion:

```
+==============================================================+
|  ++ TITAN -- BUG FIXED                                       |
+==============================================================+

Bug: [description]
Root cause: [explanation]
Hypotheses tested: [N]
Fix: [summary]
Commit: [hash]

Lesson learned: [key takeaway]
```

## Git Bisect Integration

When the bug is a regression (it used to work), use `git bisect` to find the breaking commit:

1. Identify the last known good commit (ask the user or check CI history)
2. Run `git bisect start`
3. Mark current HEAD as bad: `git bisect bad`
4. Mark the known-good commit: `git bisect good [hash]`
5. For each bisect step, run the reproduction steps and mark good/bad
6. When bisect identifies the breaking commit, examine it closely -- the hypothesis is "this commit caused the bug"
7. Run `git bisect reset` before applying the fix
8. Record the bisect results in SESSION.md

## Persistence Protocol

Debug sessions MUST survive `/clear` commands. This is achieved by writing ALL state to
`.titan/debug/[session-id]/SESSION.md` after EVERY step. The file is the single source of truth.

When resuming a session:

1. Read SESSION.md completely
2. Identify the last completed step
3. Summarize progress to the user: "Resuming debug session [id]. So far we have tested [N]
   hypotheses. [summary of findings]. Next: [next action]."
4. Continue from where you left off

## Outputs

| File | Content |
|------|---------|
| `.titan/debug/[session-id]/SESSION.md` | Complete debug session record |
| Git commit | Fix commit with root cause explanation |

## State Updates

- `STATE.md` Last Action updated
- `KNOWLEDGE.md` updated with broadly applicable lessons
- Debug session marked as RESOLVED or remains ACTIVE for next session

## Error Handling

- **Cannot reproduce:** Record "not reproducible" in SESSION.md. Ask the user for more specific reproduction steps. Suggest logging or monitoring to catch the bug in action.
- **All hypotheses exhausted:** Step back. Re-examine the observations. Consider: Is the bug description accurate? Are we looking in the right place? Generate a fresh set of hypotheses based on what we have learned. If still stuck, suggest `/titan:investigate` for deeper research.
- **Fix breaks other tests:** Revert the fix. The root cause analysis may be incomplete. Generate new hypotheses that account for the broader impact.
- **Session interrupted:** State is in SESSION.md. Resume with `/titan:debug` -- it will detect the active session automatically.

## Context Bracket Behavior

| Bracket | Adaptation |
|---------|------------|
| FRESH | Full scientific method. Generate 3-5 hypotheses. Thorough experiments. |
| MODERATE | Standard method. Generate 2-3 hypotheses. Efficient experiments. |
| DEEP | Rapid mode. Test highest-confidence hypothesis first. Save session state frequently. |
| CRITICAL | Save session state immediately. Record current hypotheses and progress. Exit with instructions for fresh session to continue. |

## What's Next

After the bug is fixed, display:

```
─────────────────────────────────────────────────
★ Recommended: Return to your main workflow.
  [If mid-build: "Continue with /titan:build for Phase NN."]
  [If mid-verify: "Continue with /titan:verify for Phase NN."]
  [If standalone: "Run /titan:progress to see your current position."]

Other options:
  /titan:test      — Generate tests to prevent this bug from recurring
  /titan:review    — Review the fix before committing
  /titan:audit     — Run a security audit if the bug was security-related
  /titan:investigate — Research more broadly if root cause is still unclear
─────────────────────────────────────────────────
```

## Tips

- The most common debugging mistake is jumping to a fix without confirming the root cause. TITAN forces you to hypothesize and experiment first. Trust the process.
- When you are stuck, the problem is almost always a wrong assumption. List your assumptions explicitly and question each one.
- `git bisect` is underused and incredibly powerful for regressions. If the bug used to work, bisect first.
- Debug sessions are valuable documentation. When a similar bug appears later, the old session is a head start.
- If debugging takes more than 3 hypothesis cycles, consider stepping back and using `/titan:investigate` to research the problem space more broadly.

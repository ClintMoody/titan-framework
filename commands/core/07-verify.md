---
name: titan:07-verify
description: Mandatory 3-part verification — reconciliation, adversarial review, and knowledge capture. Cannot be skipped.
---

# /titan:07-verify — Phase Verification (MANDATORY)

> Prove that what was built matches what was planned, stands up to adversarial scrutiny, and
> captures knowledge for future phases. This command is MANDATORY — it cannot be skipped.
> No phase is complete without verification. "It probably works" is not proof.

## Prerequisites

Before running, verify ALL of the following. If any are missing, STOP and tell the user.

- `.titan/STATE.md` exists and shows step is `verify` or `verify (ready)` or `build (partial)`
- PLAN.md exists for the current phase and has status `built` or `partial`
- At least one git commit exists on the phase branch (`titan/phase-NN-phase-name`)
- `.titan/REQUIREMENTS.md` exists (needed for AC verification)

This command is NON-SKIPPABLE. If the user asks to skip verification:
```
⚠ Verification cannot be skipped. This is a core TITAN principle.

Every phase must be reconciled against its plan, reviewed adversarially,
and its knowledge captured. This protects you from compounding errors.

The cost is 5-10 minutes. The alternative is shipping unverified code.
```

---

## Process

### Step 1 — Display Banner

Print:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — VERIFY                                          ║
╚══════════════════════════════════════════════════════════════╝
Phase N of M ▓▓▓▓▓▓▓▓░░░░░░░░ XX%

Verification is a 3-part process:
  Part 1: Reconciliation (plan vs. reality)
  Part 2: Adversarial Review (quality + correctness)
  Part 3: Knowledge Capture (learnings + decisions)
```

Read PLAN.md, STATE.md, and REQUIREMENTS.md. Identify the current phase context.

---

## PART 1 — RECONCILIATION

> Compare what was planned against what was actually built. Account for every task,
> every acceptance criterion, and every deviation.

### Step 2 — Task-Level Reconciliation

Read the git log for the phase branch. Extract all commits matching `titan(phase-NN):`.

For each task in PLAN.md, determine its status by cross-referencing commits and file changes:

| Status | Meaning | Criteria |
|--------|---------|----------|
| `DONE` | Completed as planned | Commit exists, files match plan, verification steps achievable |
| `DONE-MODIFIED` | Completed but deviated from plan | Commit exists, but approach or files differ from plan |
| `DEFERRED` | Explicitly postponed | No commit, task was marked BLOCKED or skipped during build |
| `FAILED` | Attempted but unsuccessful | Commit may exist but verification steps would fail |
| `ADDED` | Not in original plan | Commit exists but doesn't map to any planned task |

Build the reconciliation table:

```markdown
## Task Reconciliation

| Task | Planned | Actual | Status | Notes |
|------|---------|--------|--------|-------|
| T1: [title] | [planned action summary] | [what commit(s) actually did] | DONE | — |
| T2: [title] | [planned action summary] | [different approach taken] | DONE-MODIFIED | [deviation explanation] |
| T3: [title] | [planned action summary] | — | DEFERRED | Blocked by [reason] |
| —   | Not planned | [commit description] | ADDED | [why this was added] |
```

### Step 3 — Acceptance Criteria Verification

For each acceptance criterion mapped to this phase (from REQUIREMENTS.md and PLAN.md), explicitly evaluate PASS or FAIL:

```markdown
## Acceptance Criteria Verification

| AC ID | Criterion | Verdict | Evidence |
|-------|-----------|---------|----------|
| AC-1.1 | Given X, When Y, Then Z | ✓ PASS | Implemented in T1, verified by [test/inspection/output] |
| AC-1.2 | Given A, When B, Then C | ✓ PASS | Implemented in T2, verified by [evidence] |
| AC-2.1 | Given D, When E, Then F | ✗ FAIL | T3 was deferred — criterion not met |
```

Rules:
- A criterion is PASS only if there is concrete evidence (test passes, file exists, output verified).
- A criterion is FAIL if the task was deferred, failed, or the implementation doesn't satisfy the Given/When/Then.
- "It should work" is NOT evidence. Name the specific proof.

### Step 4 — Deviation Tracking

List every deviation from the plan — anything that differs from what PLAN.md specified:

```markdown
## Deviations

| # | Type | Description | Impact | Acceptable? |
|---|------|-------------|--------|-------------|
| D1 | APPROACH_CHANGE | T2 used strategy B instead of planned strategy A | Low — same outcome | Yes |
| D2 | SCOPE_ADDITION | Added error handling not in original plan | Positive — improved robustness | Yes |
| D3 | INCOMPLETE | T3 deferred due to external dependency | AC-2.1 not met | Needs resolution |
```

Deviation types: `APPROACH_CHANGE`, `SCOPE_ADDITION`, `SCOPE_REDUCTION`, `FILE_CHANGE` (different files than planned), `INCOMPLETE`, `UNPLANNED_WORK`.

### Step 5 — State Consistency Check (BLOCKING)

This check is BLOCKING. If it fails, verification cannot proceed until it is fixed.

Verify that these files are mutually consistent:
1. **STATE.md** reflects the current phase and step accurately
2. **PROJECT.md** scope has not been silently expanded or reduced
3. **ROADMAP.md** phase definitions match what was actually planned and built
4. **PLAN.md** frontmatter matches the actual build results

If ANY inconsistency is found:
```
✗ STATE CONSISTENCY CHECK FAILED

Inconsistency found:
  [description of what's inconsistent]

This must be fixed before verification can continue.
Fixing now...
```

Auto-fix if possible (e.g., update STATE.md to reflect reality). If the inconsistency requires user judgment, ask.

### Step 6 — Write SUMMARY.md

Write the reconciliation report to `.titan/phases/NN-phase-name/SUMMARY.md`:

```markdown
---
phase: NN
name: [Phase Name]
verified: [ISO timestamp]
tasks_done: [count]
tasks_modified: [count]
tasks_deferred: [count]
tasks_failed: [count]
tasks_added: [count]
ac_pass: [count]
ac_fail: [count]
deviations: [count]
---

# Phase NN — [Phase Name] — Reconciliation Summary

## Task Reconciliation
[table from Step 2]

## Acceptance Criteria
[table from Step 3]

## Deviations
[table from Step 4]

## State Consistency
✓ All state files consistent (or: details of fixes applied)
```

Print Part 1 results:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 1 — Reconciliation Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tasks:    [done]/[total] done, [modified] modified, [deferred] deferred, [added] added
  ACs:      [pass]/[total] passing
  Deviations: [count] ([acceptable count] acceptable)
  State:    ✓ Consistent
```

---

## PART 2 — ADVERSARIAL REVIEW

> An independent review that assumes bugs exist and hunts for them.
> Rubber-stamping is not allowed. The verifier MUST find at least one genuine issue.

### Step 7 — Spawn titan-verifier Agent

Launch a titan-verifier subagent with this brief:

```
AGENT: titan-verifier
TASK: Adversarial review of Phase NN — [Phase Name]

YOUR ROLE: You are an adversarial code reviewer. Your job is to find problems.
You are NOT here to congratulate the developers. You are here to catch what they missed.

PHASE CONTEXT:
- Goal: [phase goal]
- Tasks completed: [list of DONE/DONE-MODIFIED tasks with descriptions]
- Files changed: [list all files modified or created, from git diff]

ACCEPTANCE CRITERIA:
[List all ACs for this phase]

ARCHITECTURE CONSTRAINTS:
[Key constraints from ARCHITECTURE.md]

DOMAIN: [domain from config.yaml]
DOMAIN-SPECIFIC CHECKS: [checks from domain plugin, if applicable]

REVIEW THESE FILES:
[List every file modified or created during this phase. The agent should read each one.]

EVALUATE ACROSS 5 DIMENSIONS:

1. SPECIFICATION COMPLIANCE
   - Does the code satisfy every acceptance criterion? Check each one.
   - Were all verification steps from the plan actually achievable?
   - Are edge cases handled (empty inputs, boundary values, error states)?
   - Does the code handle both happy path and failure path?

2. ARCHITECTURAL COMPLIANCE
   - Does the code follow the patterns defined in ARCHITECTURE.md?
   - Are module boundaries respected?
   - Are interfaces clean and well-defined?
   - Is there unwanted coupling between components?
   - Does import/dependency structure follow project conventions?

3. CODE QUALITY
   - Are there obvious bugs (off-by-one, null reference, race conditions)?
   - Is error handling present and appropriate (not swallowed, not overly broad)?
   - Are there security basics (input validation, no hardcoded secrets, proper escaping)?
   - Is the code readable and maintainable?
   - Are there unnecessary complexities or dead code?

4. DOMAIN-SPECIFIC (loaded from domain plugin)
   [If web: accessibility, responsive design, XSS prevention, CSP, performance]
   [If mobile: battery impact, offline handling, responsive layouts, platform guidelines]
   [If audio: real-time safety, buffer management, denormals, latency]
   [If API: input validation, rate limiting, auth, error responses, versioning]
   [If no domain: skip this dimension]

5. TEST COVERAGE
   - Do tests exist for the new/modified code?
   - Do tests cover behavior (not just implementation)?
   - Are edge cases tested?
   - Do tests follow project testing conventions?
   - If no tests exist and the plan required them, flag as critical.

HALT CONDITION — MANDATORY:
If your initial review finds ZERO issues across all 5 dimensions, you MUST
re-review with increased scrutiny. Finding zero issues means you missed something.
Look harder. Check edge cases. Question assumptions. A perfect review that finds
nothing is a FAILED review.

SEVERITY LEVELS:
- CRITICAL: Must fix before phase can pass. Bugs, security issues, AC failures.
- MAJOR: Should fix before phase passes. Architecture violations, missing error handling.
- MINOR: Nice to fix. Style issues, minor improvements, documentation gaps.
- NOTE: Observation only. Good practices noticed, suggestions for future phases.

OUTPUT CONTRACT:
Return a structured evaluation with:

VERDICT: PASS | PASS-WITH-NOTES | FAIL

FINDINGS:
For each finding:
- ID: F[number]
- Severity: CRITICAL | MAJOR | MINOR | NOTE
- Dimension: [which of the 5 dimensions]
- Location: [file:line or file:function]
- Description: [what the issue is]
- Evidence: [specific code snippet or behavior that demonstrates the issue]
- Recommendation: [how to fix it]

SUMMARY:
- Total findings: [count by severity]
- Overall assessment: [2-3 sentences]
- Recommendation: [PASS / PASS-WITH-NOTES / FAIL with reasons]
```

### Step 8 — Process Verifier Results

Receive the verifier's output and process the verdict:

**If VERDICT is FAIL:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 2 — Adversarial Review: ✗ FAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Critical issues found that must be resolved:

[List each CRITICAL finding with ID, location, description, and recommendation]

Major issues:
[List MAJOR findings]

To resolve:
  1. Fix the critical issues listed above
  2. Re-run /titan:06-build for the affected tasks (or fix in-session)
  3. Re-run /titan:07-verify

Phase NN cannot proceed until critical issues are resolved.
```

**If VERDICT is PASS or PASS-WITH-NOTES:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 2 — Adversarial Review: ✓ [PASS | PASS-WITH-NOTES]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Findings: [critical] critical, [major] major, [minor] minor, [note] notes

[If PASS-WITH-NOTES, list MAJOR and MINOR findings briefly]

[If PASS, list any NOTE-level observations]
```

### Step 9 — Write EVALUATION.md

Write the full adversarial review report to `.titan/phases/NN-phase-name/EVALUATION.md`:

```markdown
---
phase: NN
name: [Phase Name]
verdict: [PASS | PASS-WITH-NOTES | FAIL]
evaluated: [ISO timestamp]
findings_critical: [count]
findings_major: [count]
findings_minor: [count]
findings_note: [count]
---

# Phase NN — [Phase Name] — Adversarial Evaluation

## Verdict: [PASS | PASS-WITH-NOTES | FAIL]

## Findings

### Critical
[findings or "None"]

### Major
[findings or "None"]

### Minor
[findings or "None"]

### Notes
[findings or "None"]

## Dimension Summary
| Dimension | Rating | Key Observations |
|-----------|--------|-----------------|
| Specification Compliance | [PASS/ISSUES] | [brief] |
| Architectural Compliance | [PASS/ISSUES] | [brief] |
| Code Quality | [PASS/ISSUES] | [brief] |
| Domain-Specific | [PASS/ISSUES/N/A] | [brief] |
| Test Coverage | [PASS/ISSUES] | [brief] |

## Overall Assessment
[2-3 sentence summary from verifier]
```

---

## PART 3 — KNOWLEDGE CAPTURE

> Extract and record what was learned during this phase so future phases benefit.

This part runs ONLY if Part 2 verdict is PASS or PASS-WITH-NOTES. If FAIL, skip to error handling.

### Step 10 — Extract Patterns and Learnings

Review the phase's build and verification process. Identify:

**Patterns That Worked Well:**
- What approaches produced clean code on the first try?
- What agent instructions led to good results?
- What file structures or conventions proved effective?

**Decisions Made During Build:**
- Any approach changes from the plan (from deviation tracking)?
- Any technology choices made during implementation?
- Any trade-offs resolved during build?

**Surprises and Learnings:**
- What was harder than expected?
- What was easier than expected?
- What would you do differently if planning this phase again?
- Any new patterns discovered?

### Step 11 — Update Knowledge Files

**Append to `.titan/KNOWLEDGE.md`:**
```markdown
## Phase NN — [Phase Name] ([date])

### Patterns
- [pattern description — what worked and why]

### Learnings
- [learning — what was surprising or useful to know]

### Anti-Patterns
- [what didn't work or caused problems]
```

**Append to `.titan/DECISIONS.md` (only if new decisions were made):**
```markdown
| [next number] | [decision description] | [rationale — why this choice] | [date] |
```

### Step 12 — Phase Completion

Print the final verification summary:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — VERIFICATION COMPLETE                           ║
╚══════════════════════════════════════════════════════════════╝

Phase NN — [Phase Name]

Part 1 — Reconciliation:  ✓ [done]/[total] tasks, [pass]/[total] ACs
Part 2 — Adversarial:     ✓ [VERDICT] ([findings count] findings)
Part 3 — Knowledge:       ✓ [patterns count] patterns, [learnings count] learnings captured

[If next phase exists in ROADMAP.md:]
★ Phase NN complete. Next: Phase [NN+1] — [Next Phase Name]
  Run /titan:05-plan to plan the next phase.
  Or run /titan:08-ship if this is the final phase of a milestone.

[If this is the last phase:]
★ All phases complete!
  Run /titan:08-ship to release this milestone.
```

---

## State Updates

**If PASS or PASS-WITH-NOTES:**
```markdown
## Current Position
- Phase: NN
- Step: complete
- Status: verified
- Last Action: Phase NN verified — [VERDICT]
- Updated: [ISO timestamp]

## Completed Phases
| NN | [Phase Name] | ✓ Verified | [date] |
```

Set `Next Action` to either:
- `Run /titan:05-plan for Phase [NN+1]` (if more phases exist)
- `Run /titan:08-ship to release milestone` (if last phase)

**If FAIL:**
```markdown
## Current Position
- Phase: NN
- Step: build (fix required)
- Status: active
- Last Action: Phase NN verification FAILED — [count] critical issues
- Updated: [ISO timestamp]

## Next Action
> Fix critical issues and re-run /titan:06-build, then /titan:07-verify
```

---

## Outputs

| Artifact | Location | Description |
|----------|----------|-------------|
| SUMMARY.md | `.titan/phases/NN-phase-name/SUMMARY.md` | Reconciliation report |
| EVALUATION.md | `.titan/phases/NN-phase-name/EVALUATION.md` | Adversarial review results |
| KNOWLEDGE.md | `.titan/KNOWLEDGE.md` | Updated with phase learnings |
| DECISIONS.md | `.titan/DECISIONS.md` | Updated with new decisions (if any) |
| STATE.md | `.titan/STATE.md` | Updated with verification result |

---

## Error Handling

| Situation | Response |
|-----------|----------|
| No commits on phase branch | "No build work found. Run `/titan:06-build` first." |
| Plan exists but no build | "Phase has a plan but no build. Run `/titan:06-build` first." |
| Verifier returns zero findings initially | Verifier must re-review (HALT CONDITION). This is enforced in the agent brief. |
| Verifier verdict is FAIL | Present critical issues. Update STATE.md. Return user to /titan:06-build. |
| State consistency check fails | Auto-fix if possible. If user judgment needed, ask before proceeding. |
| Context running low during verification | Prioritize: write SUMMARY.md and EVALUATION.md first, then knowledge capture. If CRITICAL bracket, save state and resume. |
| User asks to skip verification | Refuse. Print the non-skippable warning. This is a core TITAN principle. |
| All ACs fail | Likely the build went wrong. Suggest re-planning: "Consider running `/titan:05-plan` to restructure this phase." |

---

## What's Next

After verification completes, display based on the result:

**If PASS or PASS-WITH-NOTES:**
```
─────────────────────────────────────────────────
★ Recommended: Plan the next phase.
  [If more phases remain: "Run /titan:05-plan for Phase NN+1 — [Next Phase Name]."]
  [If all phases done: "Run /titan:08-ship to release the milestone."]

Other options:
  /titan:08-ship    — Ship now (if all phases are complete)
  /titan:audit      — Run a full audit before shipping
  /titan:05-plan    — Plan the next phase
  /titan:progress   — See full project dashboard and current position
─────────────────────────────────────────────────
```

**If FAIL:**
```
─────────────────────────────────────────────────
★ Recommended: Fix the critical issues, then re-verify.
  Run /titan:06-build to address the findings, then
  run /titan:07-verify again.

Other options:
  /titan:06-build    — Resume building to fix issues
  /titan:debug       — Debug a specific failing issue
  /titan:05-plan     — Re-plan if the approach was fundamentally wrong
─────────────────────────────────────────────────
```

## Tips

- Verification gets easier over time as knowledge accumulates. Early phases have more findings; later phases benefit from patterns learned.
- The adversarial review is your best friend. It catches issues now that would be 10x more expensive to fix after shipping.
- Pay attention to DONE-MODIFIED tasks — deviations from the plan often signal that the plan was underspecified. Feed this back into future planning.
- Knowledge capture is the compounding advantage. The more you capture, the better future phases execute.
- If verification keeps failing on the same types of issues, update your domain plugin or ARCHITECTURE.md with stricter guidelines.

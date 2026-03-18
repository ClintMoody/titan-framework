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

## PART 1b — END-TO-END VERIFICATION (v2.0)

> If `.titan/MANIFEST.json` exists (v2.0 autonomous scaffold), run E2E verification
> for all features touched in this phase BEFORE the adversarial review.

### Step 5b — E2E Feature Verification

1. Read `.titan/MANIFEST.json` — identify features related to this phase
2. For each feature that should now be "passing":
   a. Load domain-specific E2E strategy from `.titan/config.yaml`
   b. Run verification steps (build, run, test interaction, verify output)
   c. Record pass/fail per feature
3. Update MANIFEST.json status:
   - Only change "failing" → "passing" if ALL E2E checks pass
   - If E2E fails, the feature remains "failing"
4. Append E2E results to SUMMARY.md

```markdown
## End-to-End Verification

| Feature | Description | E2E Result | Notes |
|---------|-------------|-----------|-------|
| F-012 | User login flow | ✓ PASS | All 4 acceptance criteria verified |
| F-013 | Password reset | ✗ FAIL | Email not sent — SMTP config missing |
```

If any features fail E2E, note them prominently — they may generate additional findings in Part 2.

**Pairs with:** `/titan:verify-e2e` command for standalone E2E verification.

---

## PART 2 — TWO-STAGE ADVERSARIAL REVIEW

> The review is split into two independent stages with different agents and different prompts.
> This separation catches well-written-but-wrong code (Stage A) and correct-but-poorly-written
> code (Stage B) that a single reviewer would miss.
>
> **Stage A: Spec Compliance** — Does the code do what it's supposed to do?
> **Stage B: Code Quality** — Is the code well-written, secure, and maintainable?

### Anti-Rationalization Guard

Before dispatching reviewers, internalize these truths. Verification is where TITAN's quality promise is kept or broken.

| Rationalization | Why It's Wrong | What To Do Instead |
|----------------|----------------|-------------------|
| "The build passed, so verification is a formality" | Build passing means tasks completed. It says nothing about correctness or quality. | Treat every review as if bugs definitely exist. They do. |
| "We can catch this in a later phase" | Later phases build on this one. Bugs compound exponentially. | Catch it now. The cost is 5 minutes. The cost later is hours. |
| "The team can manually review this" | Manual review after AI review creates accountability gaps. Nobody owns the finding. | Every finding must be identified, documented, and assigned NOW. |
| "This phase is too small to have issues" | Small phases have fewer hiding places — but bugs per line of code is constant. | Review with the same rigor regardless of phase size. |
| "The executor reported DONE with no concerns" | The executor's report is an input, not evidence. Verify by reading code. | Verify every AC against actual code paths. |
| "Splitting into two stages is overkill" | Single-reviewer bias is documented. Spec reviewers forgive quality issues; quality reviewers forgive spec gaps. | Trust the separation. It exists because single-pass review has a known failure rate. |

### Step 7a — Stage A: Spawn Spec Compliance Reviewer

Launch a titan-verifier subagent in **Mode A** (Spec Compliance):

```
AGENT: titan-verifier
MODE: A — Spec Compliance Review
TASK: Verify Phase NN — [Phase Name] matches its specification

YOUR ROLE: You verify that the code DOES WHAT IT'S SUPPOSED TO DO.
You are checking correctness against the specification, not code quality.
Do NOT comment on style, naming, or elegance — that's Stage B's job.

PHASE CONTEXT:
- Goal: [phase goal]
- Tasks completed: [list of DONE/DONE-MODIFIED tasks with descriptions]
- Files changed: [list all files modified or created, from git diff]

ACCEPTANCE CRITERIA (check EVERY one):
[List all ACs for this phase]

ARCHITECTURE CONSTRAINTS:
[Key constraints from ARCHITECTURE.md]

REVIEW THESE FILES:
[List every file modified or created during this phase.]

EVALUATE THESE DIMENSIONS ONLY:

1. SPECIFICATION COMPLIANCE
   - Does the code satisfy every acceptance criterion? Check each one individually.
   - For each AC, trace the code path that satisfies it. Name the file and function.
   - Were all verification steps from the plan actually achievable?
   - Are edge cases handled (empty inputs, boundary values, error states)?
   - Does the code handle both happy path and failure path?
   - Is there any AC that appears satisfied but isn't actually tested?

2. ARCHITECTURAL COMPLIANCE
   - Does the code follow the patterns defined in ARCHITECTURE.md?
   - Are module boundaries respected?
   - Are interfaces clean and well-defined?
   - Is there unwanted coupling between components?
   - Does import/dependency structure follow project conventions?

DO NOT EVALUATE: Code style, naming, readability, test quality, domain-specific checks.
Those belong to Stage B. Stay in your lane.

HALT CONDITION — MANDATORY:
If you find ZERO issues, re-review. Real code always has spec gaps.
Check: Are there ACs that the code technically satisfies but in a degenerate way?
Check: Are there implicit requirements the ACs assume but don't state?

OUTPUT CONTRACT:
Return a structured evaluation with:

VERDICT: PASS | PASS-WITH-NOTES | FAIL
STAGE: A — Spec Compliance

FINDINGS:
For each finding:
- ID: SA-[number] (SA = Stage A)
- Severity: CRITICAL | IMPORTANT | MINOR
- Dimension: Specification Compliance | Architectural Compliance
- Location: [file:line or file:function]
- AC Reference: [which acceptance criterion is affected, if applicable]
- Description: [what the issue is]
- Evidence: [specific code that demonstrates the issue]
- Recommendation: [how to fix it]

SUMMARY:
- ACs verified: [count PASS] / [count total]
- Total findings: [count by severity]
- Overall assessment: [2-3 sentences]
- Recommendation: [PASS / PASS-WITH-NOTES / FAIL with reasons]
```

### Step 7b — Process Stage A Results

If Stage A verdict is **FAIL with CRITICAL spec compliance issues**, STOP HERE. Do not proceed to Stage B. Present the failures and return the user to build.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 2a — Spec Compliance Review: ✗ FAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The code does not match the specification. Stage B (Code Quality) is skipped —
there is no point reviewing quality of code that doesn't do the right thing.

Critical spec failures:
[List each SA-* CRITICAL finding]

To resolve:
  1. Fix the spec compliance issues above
  2. Re-run /titan:06-build for the affected tasks
  3. Re-run /titan:07-verify

Phase NN cannot proceed until the code matches its specification.
```

If Stage A verdict is **PASS or PASS-WITH-NOTES**, proceed to Stage B:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 2a — Spec Compliance Review: ✓ [PASS | PASS-WITH-NOTES]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ACs verified: [pass]/[total]
  Findings: [count by severity]

  Proceeding to Stage B — Code Quality Review...
```

### Step 7c — Stage B: Spawn Code Quality Reviewer

Launch a SECOND titan-verifier subagent in **Mode B** (Code Quality):

```
AGENT: titan-verifier
MODE: B — Code Quality Review
TASK: Review code quality for Phase NN — [Phase Name]

YOUR ROLE: You review whether the code is WELL-WRITTEN, SECURE, and MAINTAINABLE.
Assume the code already does what it's supposed to (spec compliance was verified in Stage A).
Do NOT re-check acceptance criteria or architectural compliance — that's already done.

PHASE CONTEXT:
- Goal: [phase goal]
- Files changed: [list all files modified or created, from git diff]

DOMAIN: [domain from config.yaml]
DOMAIN-SPECIFIC CHECKS: [checks from domain plugin, if applicable]

STAGE A RESULTS (for context only — do NOT re-evaluate):
- Verdict: [Stage A verdict]
- Key findings: [brief summary of Stage A findings, if any]

REVIEW THESE FILES:
[List every file modified or created during this phase.]

EVALUATE THESE DIMENSIONS ONLY:

3. CODE QUALITY
   - Are there obvious bugs (off-by-one, null reference, race conditions)?
   - Is error handling present and appropriate (not swallowed, not overly broad)?
   - Are there security basics (input validation, no hardcoded secrets, proper escaping)?
   - Is the code readable and maintainable?
   - Are there unnecessary complexities or dead code?
   - Is there duplication that should be extracted?

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
   - Are there tests that could give false positives (testing nothing)?

DO NOT EVALUATE: Spec compliance, acceptance criteria, architectural conformance.
Those were verified in Stage A. Stay in your lane.

HALT CONDITION — MANDATORY:
If you find ZERO issues, re-review. No code is perfect.
Check: error handling paths, security boundaries, untested edge cases.

OUTPUT CONTRACT:
Return a structured evaluation with:

VERDICT: PASS | PASS-WITH-NOTES | FAIL
STAGE: B — Code Quality

FINDINGS:
For each finding:
- ID: SB-[number] (SB = Stage B)
- Severity: CRITICAL | IMPORTANT | MINOR
- Dimension: Code Quality | Domain-Specific | Test Coverage
- Location: [file:line or file:function]
- Description: [what the issue is]
- Evidence: [specific code snippet or behavior]
- Recommendation: [how to fix it]

SUMMARY:
- Total findings: [count by severity]
- Overall assessment: [2-3 sentences]
- Recommendation: [PASS / PASS-WITH-NOTES / FAIL with reasons]
```

### Step 8 — Combine Stage Results

Merge findings from both stages into a unified verdict:

**Combined Verdict Rules:**
- **FAIL** if EITHER stage has a CRITICAL finding
- **PASS-WITH-NOTES** if either stage has IMPORTANT or MINOR findings (no CRITICALs)
- **PASS** if both stages passed clean — should be rare

**If combined VERDICT is FAIL:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 2 — Two-Stage Adversarial Review: ✗ FAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Stage A (Spec Compliance): [verdict] — [finding count]
  Stage B (Code Quality):    [verdict] — [finding count]

Critical issues found that must be resolved:

[List each CRITICAL finding from both stages with ID, location, description, recommendation]

Major issues:
[List IMPORTANT findings from both stages]

To resolve:
  1. Fix the critical issues listed above
  2. Re-run /titan:06-build for the affected tasks (or fix in-session)
  3. Re-run /titan:07-verify

Phase NN cannot proceed until critical issues are resolved.
```

**If combined VERDICT is PASS or PASS-WITH-NOTES:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Part 2 — Two-Stage Adversarial Review: ✓ [PASS | PASS-WITH-NOTES]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Stage A (Spec Compliance): [verdict] — [finding count]
  Stage B (Code Quality):    [verdict] — [finding count]

Combined findings: [critical] critical, [important] important, [minor] minor

[If PASS-WITH-NOTES, list IMPORTANT and MINOR findings briefly]

[If PASS, list any observations]
```

### Step 9 — Write EVALUATION.md

Write the full two-stage review report to `.titan/phases/NN-phase-name/EVALUATION.md`:

```markdown
---
phase: NN
name: [Phase Name]
verdict: [PASS | PASS-WITH-NOTES | FAIL]
evaluated: [ISO timestamp]
review_model: two-stage
stage_a_verdict: [PASS | PASS-WITH-NOTES | FAIL]
stage_b_verdict: [PASS | PASS-WITH-NOTES | FAIL]
findings_critical: [count]
findings_important: [count]
findings_minor: [count]
---

# Phase NN — [Phase Name] — Two-Stage Adversarial Evaluation

## Combined Verdict: [PASS | PASS-WITH-NOTES | FAIL]

## Stage A — Spec Compliance Review
**Verdict:** [PASS | PASS-WITH-NOTES | FAIL]

### Findings
[SA-* findings or "None"]

### AC Verification
| AC ID | Criterion | Verified | Evidence |
|-------|-----------|----------|----------|
| [AC-X.Y] | [criterion] | ✓/✗ | [evidence] |

## Stage B — Code Quality Review
**Verdict:** [PASS | PASS-WITH-NOTES | FAIL]

### Findings
[SB-* findings or "None"]

## Dimension Summary
| Dimension | Stage | Rating | Key Observations |
|-----------|-------|--------|-----------------|
| Specification Compliance | A | [PASS/ISSUES] | [brief] |
| Architectural Compliance | A | [PASS/ISSUES] | [brief] |
| Code Quality | B | [PASS/ISSUES] | [brief] |
| Domain-Specific | B | [PASS/ISSUES/N/A] | [brief] |
| Test Coverage | B | [PASS/ISSUES] | [brief] |

## Overall Assessment
[2-3 sentence summary combining both stages]
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

### Step 11b — Roadmap Reassessment (Cannibalized from GSD-2)

If `verification.reassess_roadmap` is true in config.yaml, review the roadmap based on what
was learned during this phase:

1. Read `.titan/ROADMAP.md`
2. Read the KNOWLEDGE.md entries just captured (Step 10-11)
3. Read the deviations from SUMMARY.md (Step 4)
4. For each remaining phase in the roadmap, assess:
   - Does this phase still make sense given what we learned?
   - Has scope changed (should it be bigger/smaller)?
   - Have new dependencies emerged?
   - Should phase order change?
5. If adjustments are needed, present them to the user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Roadmap Reassessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Based on Phase NN learnings:

  [adjustment 1] — Phase X: [what changed and why]
  [adjustment 2] — Phase Y: [what changed and why]

  [accept]  — Apply these adjustments to ROADMAP.md
  [skip]    — Keep the roadmap as-is
  [discuss] — Let me explain my concerns
```

6. If accepted: update ROADMAP.md and record the changes in DECISIONS.md
7. If skipped: note in KNOWLEDGE.md that reassessment was skipped

This prevents building on outdated assumptions. Each phase teaches something
that may invalidate later phases.

### Step 11c — Capture Background Thoughts

If `captures.enabled` is true in config.yaml:

1. Check `.titan/CAPTURES.md` for any captures logged during this phase
2. For each capture, determine if it should become:
   - A deferred item in STATE.md (add to Deferred Items table)
   - A knowledge entry (add to KNOWLEDGE.md)
   - A task for a future phase (note in roadmap reassessment)
   - Dismissed (mark as reviewed in CAPTURES.md)
3. If any captures were triaged, print:
   ```
   ◆ [N] background captures triaged: [X] → deferred, [Y] → knowledge, [Z] → dismissed
   ```

### Step 12 — Phase Completion

Print the final verification summary.

Print (as markdown, NOT in a code block):

---

## ⚡ TITAN — VERIFICATION COMPLETE

**Phase NN — [Phase Name]**

| Part | Result | Details |
|------|--------|---------|
| 1 — Reconciliation | ✓ Pass | [done]/[total] tasks, [pass]/[total] ACs |
| 2 — Adversarial | ✓ [VERDICT] | [findings count] findings, [critical count] critical |
| 3 — Knowledge | ✓ Captured | [patterns count] patterns, [learnings count] learnings |

[If next phase exists in ROADMAP.md:]
> **Phase NN complete.** Next: Phase [NN+1] — [Next Phase Name]
> Run `/titan:05-plan` to plan the next phase.

[If this is the last phase:]
> **All phases complete!** Run `/titan:08-ship` to release this milestone.

---

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

**If PASS or PASS-WITH-NOTES** (as markdown, NOT in a code block):

---

### ★ Recommended

> **Plan the next phase.**
> [If more phases remain: Run `/titan:05-plan` for **Phase NN+1 — [Next Phase Name]**.]
> [If all phases done: Run `/titan:08-ship` to **release the milestone**.]

### Other options

| Command | Action |
|---------|--------|
| `/titan:08-ship` | Ship now (if all phases are complete) |
| `/titan:audit` | Run a full audit before shipping |
| `/titan:05-plan` | Plan the next phase |
| `/titan:progress` | See full project dashboard and current position |

---

**If FAIL** (as markdown, NOT in a code block):

---

### ★ Recommended

> **Fix the critical issues, then re-verify.** Run `/titan:06-build` to address the findings, then run `/titan:07-verify` again.

### Other options

| Command | Action |
|---------|--------|
| `/titan:06-build` | Resume building to fix issues |
| `/titan:debug` | Debug a specific failing issue |
| `/titan:05-plan` | Re-plan if the approach was fundamentally wrong |

---

## Output Validation (Self-Test)

Before completing, verify that THIS COMMAND produced the expected artifacts. ALL must pass:

```
☐ SUMMARY.md exists at .titan/phases/NN-phase-name/SUMMARY.md
☐ SUMMARY.md contains Task Reconciliation table with status for every task in PLAN.md
☐ SUMMARY.md contains AC Verification table with verdict for every AC mapped to this phase
☐ SUMMARY.md contains Deviations table (even if empty)
☐ EVALUATION.md exists at .titan/phases/NN-phase-name/EVALUATION.md
☐ EVALUATION.md contains review_model: two-stage in frontmatter
☐ EVALUATION.md contains Stage A findings (with SA-* IDs) or explicit "None"
☐ EVALUATION.md contains Stage B findings (with SB-* IDs) or explicit "None"
☐ EVALUATION.md contains Dimension Summary table with all 5 dimensions
☐ KNOWLEDGE.md was updated (if verdict is PASS or PASS-WITH-NOTES)
☐ STATE.md was updated with current verification result
☐ STATE.md Next Action is set correctly based on verdict
```

If ANY validation check fails, fix it before presenting the final summary. Do NOT present a completion banner with missing artifacts.

---

## Tips

- Verification gets easier over time as knowledge accumulates. Early phases have more findings; later phases benefit from patterns learned.
- The two-stage review catches issues that single-pass review misses. Stage A finds "correct-looking code that's wrong." Stage B finds "correct code that's badly written."
- Pay attention to DONE-MODIFIED tasks — deviations from the plan often signal that the plan was underspecified. Feed this back into future planning.
- Knowledge capture is the compounding advantage. The more you capture, the better future phases execute.
- If verification keeps failing on the same types of issues, update your domain plugin or ARCHITECTURE.md with stricter guidelines.

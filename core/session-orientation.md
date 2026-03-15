# Session Orientation Protocol

## Purpose

The Session Orientation Protocol is the mandatory startup sequence for every coding-agent session in a TITAN autonomous loop. It ensures no session begins without understanding what happened before, what state the environment is in, and what to work on next.

Without this protocol, LLM coding sessions drift, repeat work, break things that were working, or build the wrong feature. The orientation protocol prevents all of these failure modes.

---

## When It Runs

- At the start of every coding-agent session, before any implementation work
- Automatically, without human prompting
- Cannot be skipped or abbreviated
- Typical duration: 1-3 minutes

---

## The Five Steps

### STEP 1: Orient

**Goal:** Understand where the project is and what happened recently.

**Actions:**

```
→ Read .titan/PROGRESS.md (last 3 session entries)
→ Read .titan/LOOP-STATE.json (current loop position)
→ Run: git log --oneline -10
```

**What to extract:**

| Question | Source |
|---|---|
| What feature was worked on last? | PROGRESS.md last entry |
| Did it pass or fail? | PROGRESS.md last entry status |
| What is the current loop position? | LOOP-STATE.json `current_feature` |
| How many features are done? | LOOP-STATE.json `manifest_progress` |
| Are there any known issues? | PROGRESS.md notes, LOOP-STATE.json `escalation_needed` |
| What commits exist? | `git log --oneline -10` |

**Failure mode this prevents:** Building a feature that was already completed, or re-breaking something that was just fixed.

---

### STEP 2: Verify Environment

**Goal:** Confirm the development environment is healthy before writing any code.

**Actions:**

```
→ Run init.sh
→ Run smoke test (project test suite with --bail or equivalent)
→ If smoke test fails → STOP. Fix existing bugs before any new work.
→ Record environment health in LOOP-STATE.json
```

**Environment health states:**

| State | Meaning | Action |
|---|---|---|
| `green` | init.sh passes, smoke test passes | Proceed to Step 3 |
| `yellow` | init.sh passes, some tests fail (non-blocking) | Proceed with caution, note in PROGRESS.md |
| `red` | init.sh fails or critical smoke test fails | Do NOT proceed. Fix environment first. |

**The Fix-Before-Build Rule:**

> If the smoke test fails, the entire session is dedicated to fixing the failure. No new feature work begins until the environment is green.

This rule exists because:
- A broken environment means previous work may have introduced regressions
- Building on a broken foundation compounds errors
- The MANIFEST protects against "productive-feeling" sessions that actually make things worse

**Recording environment health:**

After verification, update `LOOP-STATE.json`:
```json
{
  "environment_health": "green",
  "consecutive_failures": 0
}
```

If the environment was red and is now fixed:
```json
{
  "environment_health": "green",
  "consecutive_failures": 0
}
```

If the environment remains red after fix attempts:
```json
{
  "environment_health": "red",
  "consecutive_failures": 3,
  "escalation_needed": true,
  "escalation_reason": "Smoke test fails on database connection after 3 consecutive sessions"
}
```

---

### STEP 3: Select Next Task

**Goal:** Identify exactly one feature to work on this session.

**Actions:**

```
→ Read .titan/MANIFEST.json
→ Identify highest-priority feature with status "failing"
→ Check that all dependencies have status "passing"
→ Declare selected feature in PROGRESS.md
```

**Selection algorithm:**

```
1. Filter MANIFEST for features where status == "failing"
2. Sort by priority (ascending — lower number = higher priority)
3. For each candidate (in priority order):
   a. Check dependencies — all must be "passing"
   b. If dependencies met → SELECT this feature
   c. If dependencies not met → skip, try next
4. If no feature has met dependencies → escalate (blocked state)
```

**Declaring the selection:**

Append to PROGRESS.md immediately:

```markdown
## Session N — YYYY-MM-DD

- **Model:** [model identifier]
- **Feature:** F-NNN — [description]
- **Status:** in-progress
```

This declaration happens before any implementation work. It creates an audit trail even if the session crashes.

**Edge cases:**

| Situation | Action |
|---|---|
| All features are `passing` | Log completion in PROGRESS.md. The loop is done. |
| No `failing` feature has met dependencies | Set `escalation_needed: true` in LOOP-STATE.json. Log the blocker. |
| Previous session left a feature `failing` that was in-progress | Resume that feature (it is still the highest priority candidate). |
| Estimated sessions remaining is 0 but features remain | Re-estimate. Session estimates are guidance, not hard limits. |

---

### STEP 4: Work

**Goal:** Implement exactly one feature, incrementally and verifiably.

**Actions:**

```
→ Implement the selected feature
→ Write or update tests for every acceptance criterion
→ Run the full test suite (not just new tests)
→ Verify end-to-end against every acceptance criterion
→ Only mark "passing" in MANIFEST after E2E verification
```

**Implementation rules:**

1. **Single feature per session.** Do not start a second feature even if the first finishes quickly. Use remaining time for test hardening, documentation, or code cleanup.

2. **Incremental commits.** Commit working intermediate states. Do not accumulate a session's worth of changes in a single commit.

3. **Tests are mandatory.** Every acceptance criterion must have a corresponding test. If the criterion is "File picker opens on 'New Project'", there must be a test that verifies this behavior.

4. **No optimistic status updates.** The feature status in MANIFEST.json stays `"failing"` until every acceptance criterion passes in an end-to-end verification run. Writing code is not the same as finishing a feature.

5. **Do not modify other features.** If you discover a bug in a previously-passing feature, log it but do not fix it in this session unless it blocks your current feature. It will be caught by the smoke test in the next session's Step 2.

**Verification protocol:**

```
For each acceptance_criterion in feature.acceptance_criteria:
  1. Run the specific test for this criterion
  2. If test passes → criterion verified
  3. If test fails → criterion NOT verified, feature stays "failing"

If ALL criteria verified:
  → Update MANIFEST.json: status = "passing"
  → Log verification details in PROGRESS.md

If ANY criterion fails:
  → Feature stays "failing"
  → Log which criteria passed and which failed
  → Next session will resume this feature
```

---

### STEP 5: Checkpoint

**Goal:** Leave the project in a clean, resumable state.

**Actions:**

```
→ git commit with descriptive message (if uncommitted changes remain)
→ Append completed session entry to PROGRESS.md
→ Update LOOP-STATE.json with current position
→ Verify clean state: no half-implemented features, no failing tests that weren't failing at session start
```

**Commit message format:**

```
titan(build): [feature ID] [concise description of what was accomplished]
```

Examples:
```
titan(build): F-001 implement project creation with audio file import
titan(build): F-001 add acceptance tests for file format validation
titan(fix): repair database connection in smoke test
```

**PROGRESS.md session entry (completed):**

```markdown
## Session 14 — 2026-03-15

- **Model:** claude-sonnet-4-6
- **Feature:** F-023 — User can export project as WAV file
- **Status:** passing
- **Changes:**
  - Implemented `AudioExporter` class in `src/export/audio.ts`
  - Added WAV encoding with correct header generation
  - Created test suite with 8 tests covering all acceptance criteria
  - Updated `src/project/actions.ts` to include export action
- **Commits:**
  - `f4e5d6c` titan(build): F-023 implement WAV export with header generation
  - `a7b8c9d` titan(build): F-023 add acceptance tests for export flow
- **Verification:** All 5 acceptance criteria verified end-to-end
- **Next Priority:** F-024 — Batch export multiple projects
- **Environment State:** green
```

**LOOP-STATE.json update:**

Update all relevant fields to reflect the session outcome.

**Clean state rule:**

> At the end of every session, the project must be in a state where a completely new agent instance can pick up exactly where this one left off, with zero context beyond what is written in PROGRESS.md, MANIFEST.json, and LOOP-STATE.json.

This means:
- No uncommitted changes
- No half-implemented features (either the feature works or it does not)
- No temporary files or debug code left behind
- PROGRESS.md accurately reflects what happened
- LOOP-STATE.json accurately reflects the current position

---

## LOOP-STATE.json Schema

**Location:** `.titan/LOOP-STATE.json`

This file is the machine-readable snapshot of loop position. It is read at orientation (Step 1) and written at checkpoint (Step 5).

```json
{
  "loop_id": "loop-2026-03-05-001",
  "status": "running",
  "current_session": 14,
  "current_feature": "F-023",
  "last_checkpoint": "2026-03-05T14:30:00Z",
  "manifest_progress": {
    "total": 47,
    "passing": 22,
    "failing": 25
  },
  "environment_health": "green",
  "consecutive_failures": 0,
  "escalation_needed": false,
  "escalation_reason": null,
  "next_priority": "F-024",
  "estimated_sessions_remaining": 18
}
```

**Field definitions:**

| Field | Type | Description |
|---|---|---|
| `loop_id` | string | Unique identifier for this development loop. Format: `loop-YYYY-MM-DD-NNN` |
| `status` | string | One of: `running`, `paused`, `completed`, `escalated` |
| `current_session` | integer | Session counter (increments every session) |
| `current_feature` | string | Feature ID currently being worked on (or just completed) |
| `last_checkpoint` | string (ISO 8601) | Timestamp of the last successful checkpoint |
| `manifest_progress.total` | integer | Total features in MANIFEST.json |
| `manifest_progress.passing` | integer | Features with status `"passing"` |
| `manifest_progress.failing` | integer | Features with status `"failing"` or `"blocked"` |
| `environment_health` | string | One of: `green`, `yellow`, `red` |
| `consecutive_failures` | integer | Number of consecutive sessions where the smoke test failed at start. Resets to 0 on green. |
| `escalation_needed` | boolean | Whether human intervention is needed |
| `escalation_reason` | string or null | Why escalation is needed (null if not needed) |
| `next_priority` | string | Feature ID of the next feature to work on |
| `estimated_sessions_remaining` | integer | Sum of `estimated_sessions` for all `"failing"` features |

**Status transitions:**

```
running → running        (normal session completion)
running → escalated      (consecutive_failures >= 3, or no feature has met dependencies)
running → completed      (all features passing)
escalated → running      (human resolves the blocker)
paused → running         (human resumes the loop)
```

**Escalation triggers:**

| Trigger | Threshold | Action |
|---|---|---|
| Consecutive smoke test failures | >= 3 sessions | Set `escalation_needed: true` |
| No feature with met dependencies | Any occurrence | Set `escalation_needed: true` |
| Feature exceeds 3x estimated sessions | Any occurrence | Log warning in PROGRESS.md, suggest re-scoping |
| Environment health red for 2+ sessions | >= 2 sessions | Set `escalation_needed: true` |

---

## Critical Rules

### Rule 1: One Feature Per Session

A session works on exactly one feature. This prevents:
- Half-finished features that are hard to resume
- Unclear blame when tests break
- Context overload that degrades LLM output quality

If a feature is completed early, the remaining session time is spent on:
1. Hardening tests for the completed feature
2. Updating documentation
3. Code cleanup in the feature's area
4. NOT starting the next feature

### Rule 2: Fix Before Build

If the smoke test fails in Step 2, the session becomes a fix-it session. The feature selection in Step 3 is replaced with: "Fix whatever is broken."

This prevents the common failure mode where agents build new features on top of broken foundations, compounding errors until the project is unrecoverable.

### Rule 3: Clean State at Session End

Every session must end with:
- All changes committed
- PROGRESS.md updated
- LOOP-STATE.json updated
- Tests in the same or better state than session start
- No temporary files, debug logs, or commented-out code

A session that crashes or is interrupted before checkpoint is treated as a failed session. The next session's orientation will detect the inconsistency (LOOP-STATE.json will be stale relative to git log) and recover.

---

## Recovery from Interrupted Sessions

If a session is interrupted before Step 5 (Checkpoint), the next session detects this during Step 1 (Orient):

**Detection:** `git log` shows commits not reflected in LOOP-STATE.json, or LOOP-STATE.json `last_checkpoint` is older than the most recent commit.

**Recovery procedure:**

```
1. Read git log to understand what was committed
2. Run smoke test to check environment health
3. If smoke test passes:
   → Update LOOP-STATE.json to reflect actual state
   → Append recovery note to PROGRESS.md
   → Continue with normal orientation
4. If smoke test fails:
   → Treat as a fix-it session (Rule 2)
```

No special human intervention is needed for interrupted sessions. The protocol is self-healing.

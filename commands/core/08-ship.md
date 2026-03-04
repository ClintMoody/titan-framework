---
name: titan:08-ship
description: Ship a milestone — pre-flight checks, branch merges, release tagging, archival, and celebration.
---

# /titan:ship — Release a Milestone

> Ship what you've built. This command runs pre-flight checks, merges phase branches,
> creates a release tag, archives phase data, and celebrates your achievement.
> Shipping is the finish line — everything before this was preparation.

## Prerequisites

Before running, verify ALL of the following. If any are missing, STOP and tell the user.

- `.titan/STATE.md` exists
- `.titan/ROADMAP.md` exists with defined phases
- At least one phase has been verified (status `verified` or `complete` in STATE.md)
- `.titan/DECISIONS.md` exists (created during vision or build phases)
- Git repository is initialized

If no phases are verified, tell the user: "No verified phases to ship. Run `/titan:verify` on your completed phases first."

---

## Process

### Step 1 — Display Banner

Print:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — SHIP                                            ║
╚══════════════════════════════════════════════════════════════╝
```

Read STATE.md, ROADMAP.md, and all phase SUMMARY.md and EVALUATION.md files. Build a complete picture of the milestone.

### Step 2 — Pre-Flight Checklist (BLOCKING)

Every check below MUST pass. If any fails, the ship is BLOCKED until the issue is resolved. Run all checks and report results together.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Pre-Flight Checklist
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Check 1: All planned phases verified**
- Read ROADMAP.md. List every phase planned for this milestone.
- For each phase, check STATE.md completed phases table for `verified` or `complete` status.
- Check that a SUMMARY.md and EVALUATION.md exist in each phase directory.
- Result: `✓ All [count] phases verified` OR `✗ Phase(s) [list] not yet verified`

**Check 2: No FAIL evaluations unresolved**
- Read every EVALUATION.md across all phase directories.
- Check that no evaluation has verdict `FAIL`.
- PASS-WITH-NOTES is acceptable. FAIL is not.
- Result: `✓ No unresolved failures` OR `✗ Phase [NN] has FAIL verdict — resolve before shipping`

**Check 3: No critical blockers in STATE.md**
- Read STATE.md blockers table.
- If any blockers exist with no resolution, the check fails.
- Result: `✓ No active blockers` OR `✗ [count] unresolved blockers — see STATE.md`

**Check 4: All deferred items acknowledged**
- Read STATE.md deferred items table AND all SUMMARY.md deviation tables.
- Collect every deferred task and incomplete AC.
- If deferred items exist, present them to the user for acknowledgment (this is NOT blocking, but requires explicit acknowledgment):
  ```
  ⚠ Deferred items found:
    - [deferred item 1 — reason]
    - [deferred item 2 — reason]

  These will NOT be included in this release. Acknowledge? [yes / no — address them first]
  ```
- Result: `✓ No deferred items` OR `✓ [count] deferred items acknowledged by user`

**Check 5: Git working tree clean**
- Run `git status` conceptually (check for uncommitted changes).
- If dirty: `✗ Uncommitted changes detected. Commit or stash before shipping.`
- Result: `✓ Working tree clean` OR `✗ Working tree dirty — [count] uncommitted changes`

**Print checklist results:**
```
  [✓|✗] All planned phases verified          [count]/[total]
  [✓|✗] No FAIL evaluations unresolved       [details]
  [✓|✗] No critical blockers                 [details]
  [✓|✗] Deferred items acknowledged           [count] deferred
  [✓|✗] Git working tree clean               [status]
```

**If ANY check marked ✗ fails (excluding deferred acknowledgment):**
```
✗ PRE-FLIGHT FAILED

Cannot ship until the following are resolved:
  [list of failed checks with remediation steps]

Fix these issues and re-run /titan:ship.
```
STOP. Do not proceed.

**If all checks pass:**
```
✓ PRE-FLIGHT PASSED — Clear for release.
```

### Step 3 — Determine Version Number

Check if a version tag convention already exists in the repository:
- Look for existing tags matching `v*.*.*` pattern
- If found: suggest the next logical version (increment patch by default)
- If not found: suggest `v1.0.0` for first release, or `v0.1.0` if the user indicated this is pre-release during vision

Present the version to the user:
```
Suggested version: v[X.Y.Z]

Options:
  [accept]     — Use v[X.Y.Z]
  [major]      — Bump major: v[X+1.0.0]
  [minor]      — Bump minor: v[X.Y+1.0]
  [patch]      — Bump patch: v[X.Y.Z+1]
  [custom]     — Enter a custom version
  [pre-release] — Use v[X.Y.Z]-beta.[N] or -rc.[N]
```

Wait for user to confirm or select a version. Store as `RELEASE_VERSION`.

### Step 4 — Generate Release Summary

Compile the release summary from all phase artifacts:

```markdown
# Release [RELEASE_VERSION] — [Project Name]

## What Was Built

### Phase [NN] — [Phase Name]
- [Key deliverables — 2-3 bullet points from SUMMARY.md]
- Tasks: [done]/[total] completed
- Verdict: [PASS/PASS-WITH-NOTES]

### Phase [NN+1] — [Phase Name]
- [Key deliverables]
- Tasks: [done]/[total] completed
- Verdict: [PASS/PASS-WITH-NOTES]

[Repeat for each phase in this milestone]

## Key Decisions
[Top 5-10 decisions from DECISIONS.md that shaped this release, with brief rationale]

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | [decision] | [why] |
| 2 | [decision] | [why] |

## Known Limitations
[Items from deferred lists, known issues from EVALUATION.md notes, scope reductions]
- [limitation 1]
- [limitation 2]

## Metrics
- Phases completed: [count]
- Total tasks: [count] planned, [count] completed, [count] deferred
- Verification findings: [count] total ([count] critical fixed, [count] major fixed, [count] minor, [count] notes)
- Deviations from plan: [count] ([count] acceptable)
- Knowledge items captured: [count] patterns, [count] learnings

## Deferred to Future
[Items explicitly deferred, with brief reason]
- [item] — [reason]
```

Present the release summary to the user:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Release Summary — [RELEASE_VERSION]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Display the summary content above]

Review this summary. It will be included in the git tag annotation.
  [approve]  — Proceed with release
  [edit]     — Modify the summary
  [abort]    — Cancel the release
```

Wait for approval.

### Step 5 — Git Operations

Execute the following git operations in order. If ANY operation fails, stop and report the error.

**A) Determine the base branch:**
- Check `.titan/config.yaml` for a configured base branch
- If not configured: use `main` if it exists, otherwise `master`, otherwise the current default branch
- Store as `BASE_BRANCH`

**B) Merge phase branches:**

For each phase branch (in phase order):
```bash
git checkout [BASE_BRANCH]
git merge titan/phase-NN-phase-name --no-ff -m "titan(release): merge phase NN — [Phase Name]"
```

Use `--no-ff` to preserve the phase branch history in the merge commit.

If a merge conflict occurs:
```
✗ Merge conflict in phase NN branch.

Conflicting files:
  [list of conflicting files]

Options:
  [resolve] — I'll help resolve the conflicts
  [abort]   — Cancel the release and fix manually
```

If user chooses resolve: attempt auto-resolution for trivial conflicts (whitespace, non-overlapping changes). For non-trivial conflicts, present both versions and ask the user to choose.

**C) Create annotated tag:**

```bash
git tag -a [RELEASE_VERSION] -m "[Full release summary content from Step 4]"
```

**D) Verify tag was created:**
```bash
git tag -l [RELEASE_VERSION]
git log --oneline -1 [RELEASE_VERSION]
```

Print:
```
✓ Tag [RELEASE_VERSION] created on commit [short hash]
✓ [count] phase branches merged to [BASE_BRANCH]
```

### Step 6 — Archive Phase Data

Move completed phase data to the archive directory:

```
.titan/archive/[RELEASE_VERSION]/
  ├── phases/
  │   ├── NN-phase-name/
  │   │   ├── PLAN.md
  │   │   ├── SUMMARY.md
  │   │   ├── EVALUATION.md
  │   │   └── EXPLORATION.md (if exists)
  │   └── ...
  ├── RELEASE_SUMMARY.md    (the summary from Step 4)
  └── manifest.yaml         (metadata about the release)
```

Create the archive directory structure. Copy (not move) phase files to the archive. Then clean up the active phases directory:
- Remove completed phase directories from `.titan/phases/`
- Keep any phase directories that belong to future milestones

Write `manifest.yaml`:
```yaml
version: [RELEASE_VERSION]
date: [ISO timestamp]
phases: [count]
tasks_completed: [count]
tasks_deferred: [count]
base_branch: [BASE_BRANCH]
final_commit: [full commit hash]
```

### Step 7 — Update STATE.md

```markdown
## Current Position
- Phase: —
- Step: shipped
- Status: milestone complete
- Last Action: Released [RELEASE_VERSION]
- Updated: [ISO timestamp]

## Completed Milestones
| Version | Phases | Date | Notes |
|---------|--------|------|-------|
| [RELEASE_VERSION] | [phase list] | [date] | [brief description] |

## Completed Phases
[Keep existing completed phases table, add milestone marker]

## Active Decisions
[Clear decisions that were resolved in this milestone]

## Deferred Items
[Keep items deferred to future milestones]

## Next Action
> Milestone [RELEASE_VERSION] shipped. Start next milestone with /titan:vision or /titan:plan.
```

### Step 8 — Celebration Banner

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ★  SHIPPED — [RELEASE_VERSION]  ★                         ║
║                                                              ║
║   [Project Name]                                             ║
║                                                              ║
║   Phases: [count] completed                                  ║
║   Tasks:  [count] done                                       ║
║   Quality: [total findings] issues found and resolved        ║
║   Knowledge: [count] patterns captured                       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Congratulations. You just shipped world-class software.

What's next?

  /titan:vision    — Start a new milestone with new goals
  /titan:plan      — Plan the next phase if more phases exist in the roadmap
  /titan:progress  — View the full project history and metrics

[If remote is configured:]
  To push to remote:
    git push origin [BASE_BRANCH]
    git push origin [RELEASE_VERSION]

[If no remote:]
  No remote configured. When ready, push with:
    git remote add origin [url]
    git push -u origin [BASE_BRANCH] --tags
```

---

## Outputs

| Artifact | Location | Description |
|----------|----------|-------------|
| Merge commits | `[BASE_BRANCH]` branch | One merge commit per phase |
| Git tag | `[RELEASE_VERSION]` | Annotated tag with release summary |
| Archive | `.titan/archive/[RELEASE_VERSION]/` | Archived phase plans, summaries, evaluations |
| RELEASE_SUMMARY.md | `.titan/archive/[RELEASE_VERSION]/RELEASE_SUMMARY.md` | Complete release summary |
| manifest.yaml | `.titan/archive/[RELEASE_VERSION]/manifest.yaml` | Release metadata |
| STATE.md | `.titan/STATE.md` | Updated to milestone complete |

---

## State Updates

- STATE.md `Phase` cleared (or set to next milestone's first phase if roadmap continues)
- STATE.md `Step` set to `shipped`
- STATE.md `Status` set to `milestone complete`
- STATE.md `Completed Milestones` table updated
- STATE.md `Next Action` set to guidance for next steps
- Active phase directories cleaned and archived

---

## Error Handling

| Situation | Response |
|-----------|----------|
| Pre-flight fails | Report which checks failed with specific remediation. Do not proceed. |
| No verified phases | "No phases to ship. Complete the plan-build-verify cycle first." |
| Merge conflict | Present conflict details. Offer to help resolve or let user handle manually. |
| Tag already exists | "Tag [version] already exists. Choose a different version number." |
| Git operations fail | Report the exact error. Offer to rollback any partial merges with `git merge --abort`. |
| User aborts during release | Rollback any merges performed so far. Restore original branch state. STATE.md unchanged. |
| Archive directory already exists | "Archive for [version] already exists. This version may have been partially shipped. Overwrite? [yes/no]" |
| No base branch found | Ask user to specify: "Which branch should phase branches merge into?" |
| Remote push fails | This command does NOT push automatically. It only suggests push commands. Push failures are the user's responsibility. |
| Deferred items not acknowledged | Re-present deferred items. Cannot proceed without acknowledgment. |

---

## Important Notes

- This command does NOT push to remote. It only performs local git operations (merge + tag). Pushing is explicitly left to the user. The celebration banner includes push instructions.
- Phase branches are NOT deleted after merge. They remain as historical references. The user can delete them manually if desired.
- The archive preserves a complete record of every phase's plan, execution, and evaluation. This is your project's institutional memory.
- If the roadmap has additional phases beyond this milestone, STATE.md will guide the user to continue planning. A new milestone doesn't require re-running `/titan:init` or `/titan:vision` — just `/titan:plan` for the next phase.

---

## What's Next

After shipping, display based on the roadmap state:

**If more phases remain in the roadmap:**
```
─────────────────────────────────────────────────
★ Recommended: Run /titan:plan to plan Phase NN — [Next Phase Name].
  Your roadmap shows [X] phases remaining.

Other options:
  /titan:vision    — Revisit the roadmap if priorities have shifted
  /titan:explore   — Research unknowns before planning the next phase
  /titan:progress  — See full project dashboard and current position
  /titan:pause     — Save state and take a break — you've earned it
─────────────────────────────────────────────────
```

**If the roadmap is complete (all phases shipped):**
```
─────────────────────────────────────────────────
★ Congratulations — your roadmap is complete!

What now?
  /titan:vision    — Define a new milestone with new goals
  /titan:audit     — Run a comprehensive quality audit of the shipped product
  /titan:progress  — Review the full project history
─────────────────────────────────────────────────
```

## Tips

- Ship early, ship often. Small milestones with 2-3 phases ship cleaner than large milestones with 10 phases.
- The release summary is your changelog. Write it for future-you who needs to understand what this version contained.
- Archive data is searchable. Future `/titan:learn` or `/titan:investigate` sessions can reference archived decisions and patterns.
- If you're unsure whether to ship, you're probably ready. The verification step already proved correctness. Shipping is just the ceremony.
- Consider creating a CHANGELOG.md in your project root from the release summary. This is not done automatically, but is recommended for open-source projects.

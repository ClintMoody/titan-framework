---
name: titan:pause
description: Save session state and create handoff document for seamless continuation
---

# /titan:pause — Session Save & Handoff

> Run this command before ending any session to ensure seamless continuation next time.

## Prerequisites

- `.titan/` directory exists with `STATE.md`.
- Active work has been done in this session (otherwise there's nothing to save).

## Process

### Step 1: Display Pause Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — SESSION PAUSE                                    ║
╚══════════════════════════════════════════════════════════════╝

  Saving session state...
```

### Step 2: Capture Current State

Gather all relevant context about the current session:

1. **Current position:** Read STATE.md for phase, step, status.
2. **Active plan:** Read current PLAN.md (if exists) for task statuses.
3. **Uncommitted work:** Run `git status` to identify any changes.
4. **Recent commits:** Run `git log --oneline -10` to see what was committed this session.
5. **Recent decisions:** Check DECISIONS.md for entries from today.
6. **Recent knowledge:** Check KNOWLEDGE.md for entries from today.

### Step 3: Update STATE.md

Update `.titan/STATE.md` with:

- Status: `paused`
- Last Action: description of the most recent work completed
- Updated: current ISO 8601 timestamp
- Next Action: the exact next thing to do when resuming

Preserve all other sections (Completed Phases, Active Decisions, Deferred Items, Blockers, Knowledge Snapshots).

### Step 4: Create HANDOFF.md

Write `.titan/HANDOFF.md` with full narrative context. This is the primary cross-session continuity document. Write it as if explaining the situation to a fresh AI session with zero prior context.

```markdown
# TITAN Session Handoff

> Created: [ISO 8601 timestamp]
> Session Duration: [approximate time if known]

## What Was Done This Session

[Narrative description of all work completed. Be specific — mention file names,
function names, component names. 4-8 bullet points covering every significant action.]

- [Action 1 — specific files and changes]
- [Action 2 — specific files and changes]
- ...

## What Is Currently In Progress

[Description of any work that was started but not completed. Include exactly
where things stand — which task, which file, which line of thinking.]

- Task: [task name from PLAN.md if applicable]
- Status: [how far along — percentage or specific milestone]
- Current file: [file being worked on]
- Current state: [what has been written/changed so far]

## What Was Tried But Didn't Work

[CRITICAL: Document any approaches that were attempted and abandoned. This
prevents the next session from wasting time on the same dead ends.]

- [Approach that failed and why]
- [Another failed approach if any]

## Key File Paths

[Every file that was created, modified, or is important for continuing work.]

- `[path/to/file1]` — [what it is / what was changed]
- `[path/to/file2]` — [what it is / what was changed]
- ...

## Current Blockers

[Any issues preventing progress. Include error messages, dependency problems,
or decisions that need to be made.]

- [Blocker 1 — description and impact]
- [Blocker 2 if any]

## Exact Next Step

[The single most important thing the next session should do FIRST. Be precise
enough that someone with no context can start immediately.]

> [One sentence: do THIS in THIS file for THIS reason]

## Gotchas and Warnings

[Anything the next session needs to be careful about.]

- [Warning 1 — e.g., "Don't modify X until Y is resolved"]
- [Warning 2 — e.g., "The test suite takes 3 minutes to run"]

## Context References

- STATE.md: `.titan/STATE.md`
- Current Plan: `.titan/phases/[NN-name]/PLAN.md`
- Config: `.titan/config.yaml`
- Decisions: `.titan/DECISIONS.md`
- Knowledge: `.titan/KNOWLEDGE.md`
```

### Step 5: Handle Uncommitted Work

Check `git status` for any uncommitted changes.

**If uncommitted changes exist:**

1. Stage all tracked modified files: `git add -u`
2. Also stage any new files that are part of the current task (use judgment — don't stage unrelated files).
3. Commit with message: `titan(wip): session pause — [brief description of incomplete work]`
4. Print: "✓ Work-in-progress committed."

**If no uncommitted changes:**
- Print: "✓ All work already committed."

### Step 6: Stage and Commit State Files

Commit the state files themselves:

```bash
git add .titan/STATE.md .titan/HANDOFF.md .titan/DECISIONS.md .titan/KNOWLEDGE.md
git commit -m "titan(state): session pause — handoff created"
```

### Step 7: Display Confirmation

Print:

```
╔══════════════════════════════════════════════════════════════╗
║  ✓ TITAN — SESSION SAVED                                     ║
╚══════════════════════════════════════════════════════════════╝

  State:    .titan/STATE.md (updated)
  Handoff:  .titan/HANDOFF.md (created)
  Git:      [committed / no changes]

  To resume next session:
  ─────────────────────────────────────────────────
  Run /titan:resume
  ─────────────────────────────────────────────────

  The handoff document contains full context for
  seamless continuation, even after long breaks.
```

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| STATE.md | `.titan/STATE.md` | Updated with current position and paused status |
| HANDOFF.md | `.titan/HANDOFF.md` | Full narrative for next session restoration |
| WIP commit | git history | Preserves any uncommitted work |

## State Updates

- STATE.md `Status` → `paused`
- STATE.md `Last Action` → description of session work
- STATE.md `Updated` → current timestamp
- STATE.md `Next Action` → exact next step

## Error Handling

| Error | Resolution |
|-------|-----------|
| No `.titan/` directory | Inform user — nothing to pause |
| Git not available | Skip git operations, still create HANDOFF.md and update STATE.md |
| Git commit fails (hooks) | Warn user, suggest manual commit; state files are still written |
| HANDOFF.md already exists | Overwrite it — the new one is more current |

## What's Next

After the session is saved, display:

```
─────────────────────────────────────────────────
★ Session saved. When you return, run:

  /titan:resume    — Restores full context and tells you exactly
                     where to pick up.

  Everything is saved in STATE.md and HANDOFF.md.
  You can close this session safely.
─────────────────────────────────────────────────
```

## Tips

- Always run `/titan:pause` before ending a session, especially before long breaks.
- The handoff narrative is more valuable than STATE.md alone — it captures the "why" and "how" that structured state cannot.
- If you're just taking a short break (same day), `/titan:pause` is still recommended but less critical — STATE.md alone is usually sufficient for same-day resumes.
- The "What Was Tried But Didn't Work" section is often the most valuable part of the handoff. Don't skip it.

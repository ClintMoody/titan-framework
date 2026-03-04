---
name: titan:resume
description: Continue from previous session — restore context from HANDOFF.md or STATE.md
---

# /titan:resume — Session Continuation

> Run this command at the start of any session to pick up exactly where you left off.

## Prerequisites

- `.titan/` directory exists (project is initialized).
- `.titan/STATE.md` exists (minimum requirement).

If `.titan/` does not exist, print:
```
⚠ No TITAN project found in this directory.
  Run /titan:init to initialize a new project.
```
And stop.

## Process

### Step 1: Display Resume Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — SESSION RESUME                                   ║
╚══════════════════════════════════════════════════════════════╝

  Restoring project context...
```

### Step 2: Check for HANDOFF.md (Priority Source)

Look for `.titan/HANDOFF.md`. This file takes priority over STATE.md because it contains full narrative context written specifically for cross-session continuity.

**If HANDOFF.md exists:**

1. Read the entire file.
2. Present a structured summary to the user:

```
◆ Handoff Document Found

  Last Session:
    [summary of what was done — 2-3 lines]

  In Progress:
    [what was actively being worked on]

  Next Step:
    [the exact next action from the handoff]

  Gotchas:
    [any warnings, failed approaches, or things to watch for]

  Key Files:
    [list of important file paths mentioned in handoff]
```

3. Ask the user: "Does this look correct? Ready to continue from here? (y/n)"
4. If confirmed:
   - Archive the handoff: copy `.titan/HANDOFF.md` to `.titan/handoffs/handoff-[ISO-date].md`
   - Delete `.titan/HANDOFF.md`
   - Print: "✓ Handoff archived. Context restored."
5. If not confirmed:
   - Ask what needs to change
   - Let user provide corrections before continuing

**After processing HANDOFF.md, fall through to Step 3 to also read current STATE.md.**

### Step 3: Read STATE.md

Read `.titan/STATE.md` completely. Extract:

- Current phase number and name
- Current step (plan/build/verify)
- Status (active/paused/blocked)
- Last action performed
- Any blockers
- The next action recommendation

Present the current position:

```
⚡ Current Position
  ─────────────────────────────────────────────────
  Phase:   [NN] — [Phase Name]
  Step:    [plan|build|verify]
  Status:  [active|paused|blocked]
  Last:    [last action description]
  Updated: [timestamp from STATE.md]
  ─────────────────────────────────────────────────
```

### Step 4: Check for In-Progress Work

Scan for incomplete work:

1. **Active PLAN.md:** Check `.titan/phases/[current-phase]/PLAN.md` for any tasks marked in-progress or incomplete.
2. **Uncommitted changes:** Run `git status` to check for staged or unstaged changes.
3. **WIP commits:** Run `git log --oneline -5` to check for any WIP commit messages.

If any found, report:

```
◆ In-Progress Items Detected
  - [list each item: plan tasks, uncommitted files, WIP commits]
```

### Step 5: Load Supporting Context

Read these files if they exist (do NOT display their full content — just note key highlights):

- `.titan/DECISIONS.md` — Note the last 3 decisions
- `.titan/KNOWLEDGE.md` — Note any recent learnings
- `.titan/config.yaml` — Note domain and profile

```
◆ Project Context
  Domain:   [domain from config]
  Profile:  [profile from config]
  Decisions: [count] recorded ([last decision summary])
  Knowledge: [count] entries
```

### Step 6: Suggest Exactly ONE Next Action

Use this decision table to determine the single best next action:

| Current State | Suggested Action |
|---------------|-----------------|
| Mid-build (tasks in progress) | "Continue building: [specific task description]" |
| Plan exists, build not started | "Start building phase [NN]: run `/titan:build`" |
| Phase build complete, not verified | "Verify phase [NN]: run `/titan:verify`" |
| Phase verified, next phase planned | "Start planning next phase: run `/titan:plan`" |
| Phase verified, no next phase | "Plan next phase from ROADMAP.md or run `/titan:ship` if complete" |
| Blocker exists | "Resolve blocker: [blocker description]" |
| No active phase | "Define project vision: run `/titan:vision`" |
| Vision exists, no exploration | "Explore the problem space: run `/titan:explore`" |
| Exploration done, no design | "Design the solution: run `/titan:design`" |

Present the suggestion:

```
★ Suggested Next Action
  ─────────────────────────────────────────────────
  [One clear, specific action with the command to run]
  ─────────────────────────────────────────────────
```

### Step 7: Ready Confirmation

Print:

```
✓ Session restored. Ready to continue.

  Quick commands:
    /titan:progress  — Full project dashboard
    /titan:help      — Command reference
```

## Outputs

No new artifacts are created. Existing HANDOFF.md is archived if present.

## State Updates

- STATE.md `Status` field updated to `active` if it was `paused`
- STATE.md `Updated` timestamp refreshed

## Error Handling

| Error | Resolution |
|-------|-----------|
| No `.titan/` directory | Direct user to `/titan:init` |
| STATE.md missing | Check if HANDOFF.md exists; if neither, suggest `/titan:init` |
| STATE.md corrupted/unparseable | Attempt to recover from HANDOFF.md or git history |
| HANDOFF.md references files that no longer exist | Warn user, suggest checking git log for changes |
| Git not available | Skip git-related checks, continue with state files only |

## Tips

- If you're resuming the same day, HANDOFF.md usually won't exist — STATE.md is sufficient.
- If something feels wrong after resume, run `/titan:progress` for a full dashboard view.
- You can always re-read the handoff from `.titan/handoffs/` if you need historical context.
- For long gaps between sessions, HANDOFF.md is invaluable — always run `/titan:pause` before ending a session.

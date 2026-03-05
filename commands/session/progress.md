---
name: titan:progress
description: Display comprehensive project status dashboard — phases, tasks, blockers, and metrics
---

# /titan:progress — Project Status Dashboard

> Run this command anytime to get a complete, scannable view of the project's current state.

## Prerequisites

- `.titan/` directory exists with `STATE.md`.

## Process

### Step 1: Display Dashboard Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — PROJECT DASHBOARD                                ║
╚══════════════════════════════════════════════════════════════╝
```

### Step 2: Read All State Sources

Gather data from these files (skip any that don't exist):

1. `.titan/STATE.md` — current position, blockers, deferred items
2. `.titan/config.yaml` — project name, domain, profile
3. `.titan/DECISIONS.md` — all decisions
4. `.titan/KNOWLEDGE.md` — all knowledge entries
5. `.titan/ROADMAP.md` — full phase roadmap (if exists)
6. Current phase `PLAN.md` — task statuses (if exists)
7. `git log --oneline -10` — recent commit activity

### Step 3: Display Project Header

```
  Project:  [project name]
  Domain:   [domain]          Profile: [profile]
  Type:     [greenfield|brownfield]
  Status:   [active|paused|blocked]
```

### Step 4: Display Phase Progress

Calculate overall progress from ROADMAP.md (total phases vs completed phases).

```
  Overall Progress
  ─────────────────────────────────────────────────
  Phase [current] of [total]: [current phase name]

  [phase-bar visualization]

  Completed Phases:
  │ Phase │ Name                    │ Status      │ Date       │
  │───────│─────────────────────────│─────────────│────────────│
  │ 01    │ [name]                  │ ✓ Complete  │ [date]     │
  │ 02    │ [name]                  │ ✓ Complete  │ [date]     │
  │ 03    │ [name]                  │ ⚡ Active    │ —          │
  │ 04    │ [name]                  │ ○ Pending   │ —          │
  │ ...   │ ...                     │ ...         │ ...        │
```

For the progress bar, use:
- `▓` for completed phases
- `▒` for active phase
- `░` for pending phases
- Format: `Phase 3 of 8 ▓▓▓▓▓▒░░░░░░░░░░ 37%`

### Step 5: Display Current Phase Tasks

If a PLAN.md exists for the current phase, show task status:

```
  Current Phase Tasks
  ─────────────────────────────────────────────────
  │ #  │ Task                          │ Status     │ Type       │
  │────│───────────────────────────────│────────────│────────────│
  │ 01 │ [task description]            │ ✓ Done     │ agent      │
  │ 02 │ [task description]            │ ◆ Active   │ in-session │
  │ 03 │ [task description]            │ ○ Pending  │ agent      │

  Progress: 1/3 tasks complete (33%)
```

If no PLAN.md exists:
```
  Current Phase Tasks
  ─────────────────────────────────────────────────
  No plan created yet. Run /titan:05-plan to create one.
```

### Step 6: Display Blockers

```
  Blockers
  ─────────────────────────────────────────────────
```

If blockers exist in STATE.md:
```
  ⚠ [blocker count] Active Blocker(s):
  │ Blocker                │ Impact        │ Proposed Resolution     │
  │────────────────────────│───────────────│─────────────────────────│
  │ [description]          │ [impact]      │ [resolution]            │
```

If no blockers:
```
  ✓ No active blockers.
```

### Step 7: Display Recent Decisions

Show the last 3 decisions from DECISIONS.md:

```
  Recent Decisions
  ─────────────────────────────────────────────────
  │ # │ Decision                        │ Date       │
  │───│─────────────────────────────────│────────────│
  │ 7 │ [decision summary]              │ [date]     │
  │ 6 │ [decision summary]              │ [date]     │
  │ 5 │ [decision summary]              │ [date]     │

  Total: [N] decisions recorded. See .titan/DECISIONS.md for full log.
```

If no decisions beyond init:
```
  Recent Decisions
  ─────────────────────────────────────────────────
  No decisions beyond initialization defaults.
```

### Step 8: Display Knowledge Highlights

Show the last 3 notable entries from KNOWLEDGE.md:

```
  Knowledge Highlights
  ─────────────────────────────────────────────────
  • [learning or pattern — one line summary]
  • [learning or pattern — one line summary]
  • [learning or pattern — one line summary]

  Total: [N] knowledge entries. See .titan/KNOWLEDGE.md for full base.
```

If no knowledge entries beyond init:
```
  Knowledge Highlights
  ─────────────────────────────────────────────────
  No knowledge entries beyond project facts.
```

### Step 9: Display Git Activity

```
  Recent Activity (Git)
  ─────────────────────────────────────────────────
  [last 5 commit messages, one-line format]
```

### Step 10: Display Suggested Next Action

Use the same decision table as `/titan:resume` Step 6. Print (as markdown, NOT in a code block):

---

### ★ Next Action

> [specific action with command from the decision table]

---

## Outputs

No artifacts are created. This command is read-only.

## State Updates

None. This command does not modify any state files.

## Error Handling

| Error | Resolution |
|-------|-----------|
| STATE.md missing | Display minimal dashboard with what's available |
| ROADMAP.md missing | Skip phase overview, show only current position |
| PLAN.md missing | Note "no plan for current phase" |
| Git not available | Skip git activity section |
| Corrupted state files | Show what can be parsed, warn about corruption |

## Tips

- Run `/titan:progress` whenever you feel lost — it shows exactly where things stand.
- The dashboard is designed to be scannable in under 10 seconds.
- Compare the "Phase Tasks" section against actual code to catch any drift.
- If the dashboard shows stale data, run `/titan:07-verify` on the current phase to reconcile.

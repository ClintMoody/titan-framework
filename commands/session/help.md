---
name: titan:help
description: Complete command reference — the Golden Path, power tools, session management, and workflows
---

# /titan:help — Command Reference

> Run this command to see every available TITAN command with usage guidance.

## Prerequisites

None. This command works at any time.

## Process

### Step 1: Display Help Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — COMMAND REFERENCE                                ║
╚══════════════════════════════════════════════════════════════╝

  The complete software development framework for building
  world-class products.

  One person + TITAN = unstoppable.
```

### Step 2: Display the Golden Path

```
  THE GOLDEN PATH — 9 Core Commands
  ═══════════════════════════════════════════════════

  Follow these in order for any new project:

  01. /titan:01-init       Initialize project — scaffold .titan/, detect type, configure domain
  02. /titan:02-vision     Define vision — project scope, requirements, architecture, roadmap
  03. /titan:03-bootstrap  Create autonomous scaffold — MANIFEST, init.sh, docs, prompts
  04. /titan:04-explore    Discover unknowns — research, prior art, technology evaluation
  05. /titan:05-design     Design UI/UX — conversational design → browser-testable mockups
  06. /titan:06-plan       Plan execution — research codebase → task plan with ACs and waves
  07. /titan:07-build      Build phase — orchestrate executor agents → atomic commits
  08. /titan:08-verify     Prove quality — reconciliation + adversarial review (MANDATORY)
  09. /titan:09-ship       Release — pre-flight checks → merge → tag → release notes

  Repeat steps 06-08 for each phase in your roadmap.

  ┌──────────────────────────────────────────────────────────────────────┐
  │  init → vision → bootstrap → explore → design → plan → build → verify → ship  │
  │                                                  ↑_______________↩             │
  └──────────────────────────────────────────────────────────────────────┘
```

### Step 3: Display Power Tools

```
  POWER TOOLS — Use Anytime
  ═══════════════════════════════════════════════════

  Problem Solving:
    /titan:investigate  Systematic novel problem analysis — hypothesize, evaluate, recommend
    /titan:experiment   Isolated prototyping — try approaches, measure, compare, decide
    /titan:debug        Scientific debugging — reproduce, hypothesize, test, verify fix
    /titan:learn        Research a technology — study before using, capture in knowledge base

  Code Quality:
    /titan:review       On-demand adversarial code review of any files or changes
    /titan:test         Generate tests — unit, integration, edge cases; supports TDD
    /titan:audit        Security + performance + accessibility + domain audit
    /titan:refactor     Safe refactoring with test preservation and rollback plan

  Project Management:
    /titan:scan         Deep codebase analysis — 4 parallel researchers, full report
    /titan:quick        Small task with full quality guarantees — for changes < 1 hour
```

### Step 3b: Display Power Tools (v2.2 Additions)

```
  POWER TOOLS (v2.2)
  ═══════════════════════════════════════════════════

    /titan:capture      Capture a stray thought — appends to .titan/captures.md, returns instantly
```

### Step 4: Display Session Management

```
  SESSION MANAGEMENT
  ═══════════════════════════════════════════════════

    /titan:resume       Restore context from HANDOFF.md or STATE.md — run first each session
    /titan:pause        Save state + create handoff document — run before ending a session
    /titan:progress     Project status dashboard — phases, tasks, blockers, metrics
    /titan:autopilot    Supervised autonomous mode — pauses between phases for review
    /titan:autopilot-full  Full autonomous mode — walk-away execution, self-chaining
    /titan:settings     Configure model profiles, domain, git, context preferences
    /titan:help         This command reference (you are here)

  AUTONOMOUS LOOP (v2.0)
  ═══════════════════════════════════════════════════

    /titan:03-bootstrap  Create autonomous scaffold — MANIFEST, init.sh, docs, prompts
    /titan:loop-start    Start autonomous loop — continuous feature development
    /titan:loop-stop     Gracefully stop the loop after current feature completes
    /titan:loop-status   Loop dashboard — health, progress, escalation status
    /titan:verify-e2e    End-to-end feature verification — test like a user
    /titan:enforce       Run architectural enforcement suite manually
```

### Step 5: Display Quick Start Guide

```
  QUICK START
  ═══════════════════════════════════════════════════

  New Project (Manual):
    1. /titan:01-init          (one time — set up TITAN)
    2. /titan:02-vision        (one time — define what you're building)
    3. /titan:06-plan          (per phase — create execution plan)
    4. /titan:07-build         (per phase — implement the plan)
    5. /titan:08-verify        (per phase — prove it works)
    6. /titan:09-ship          (per milestone — release it)

  New Project (Autonomous):
    1. /titan:01-init          (one time — set up TITAN)
    2. /titan:02-vision        (one time — define what you're building)
    3. /titan:03-bootstrap     (one time — create autonomous scaffold)
    4. /titan:loop-start       (starts autonomous loop — features built overnight)

  Returning to Work:
    1. /titan:resume        (always run this first)
    2. Follow the suggested next action

  Quick Fix (small change):
    1. /titan:quick         (handles the full cycle for small tasks)

  Stuck on a Problem:
    1. /titan:investigate   (research and hypothesize)
    2. /titan:experiment    (try approaches in isolation)
```

### Step 6: Display Common Workflows

```
  COMMON WORKFLOWS
  ═══════════════════════════════════════════════════

  New Project (Greenfield — Manual):
    init → vision → design → plan → build → verify → ship

  New Project (Greenfield — Autonomous):
    init → vision → bootstrap → loop-start → (overnight) → loop-status → ship

  Existing Project (Brownfield):
    init → scan → vision → plan → build → verify → ship

  Resume After Break:
    resume → (follow suggested action)

  Debug an Issue:
    debug → (fix) → verify

  Research Unknown Technology:
    learn → investigate → experiment → (integrate into plan)

  Add a Quick Feature:
    quick → (done — includes plan + build + verify)

  Security/Performance Audit:
    audit → (address findings) → verify

  Refactor Safely:
    refactor → verify → (confirm no regressions)
```

### Step 7: Display Symbols Legend

```
  SYMBOLS
  ═══════════════════════════════════════════════════
  ✓  Complete / Success          ✗  Failed / Error
  ◆  In Progress                 ○  Pending / Not Started
  ⚡ Active / Current            ⚠  Warning / Attention
  ★  Milestone / Important
```

### Step 8: Display Footer

```
  ─────────────────────────────────────────────────
  Project state:    .titan/STATE.md
  Configuration:    .titan/config.yaml
  Decisions:        .titan/DECISIONS.md
  Knowledge:        .titan/KNOWLEDGE.md

  Tip: Start every session with /titan:resume
       End every session with /titan:pause
  ─────────────────────────────────────────────────
```

## Outputs

No artifacts are created. This command is purely informational.

## State Updates

None.

## Error Handling

This command cannot fail — it displays static reference content.

If `.titan/` does not exist, still display the full help but add a note at the top:

```
  ⚠ No TITAN project found. Run /titan:01-init to get started.
```

## What's Next

After displaying help, if `.titan/STATE.md` exists, read it and display (as markdown, NOT in a code block):

---

### ★ Based on your current project state:

> [Read STATE.md Next Action field and display it here]

### Other options

| Command | Action |
|---------|--------|
| `/titan:progress` | Full project dashboard with phase details |
| `/titan:resume` | Restore full context from last session |

---

If no `.titan/` project exists (as markdown, NOT in a code block):

---

### ★ Ready to start?

> Run `/titan:01-init` to create your project.

### Other options

| Command | Action |
|---------|--------|
| `/titan:quick` | Skip setup and do a small task with full quality |

---

## Tips

- Bookmark the Golden Path — those 9 commands cover 95% of development work.
- Power tools are optional but powerful — use them when the situation calls for it.
- When in doubt, run `/titan:progress` to see where you are, then follow the suggested next action.
- The best command to learn first is `/titan:quick` — it gives you the full TITAN experience in a single command for small tasks.

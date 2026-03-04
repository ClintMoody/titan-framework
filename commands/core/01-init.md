---
name: titan:01-init
description: Initialize TITAN project — scaffold .titan/ directory, detect project type, configure domain
---

# /titan:01-init — Project Initialization

> Run this command at the very start of a new project, or when adding TITAN to an existing codebase.

## Prerequisites

- You are in the root directory of a project (or about to create one).
- No `.titan/` directory exists yet. If one does, inform the user: "This project is already initialized. Use `/titan:resume` to continue or delete `.titan/` to start over."

## Process

### Step 1: Display Welcome Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — PROJECT INITIALIZATION                          ║
╚══════════════════════════════════════════════════════════════╝

  The complete software development framework for building
  world-class products.

  One person + TITAN = unstoppable.
```

### Step 2: Detect Git Repository

Check if the current directory is inside a git repository by running `git rev-parse --is-inside-work-tree`.

**If git repo exists:**
- Print: "✓ Git repository detected."
- Note the current branch name for later use.

**If NO git repo:**
- Print: "○ No git repository detected."
- Ask: "Would you like me to initialize a git repository? (recommended)"
- If yes: run `git init`, create a `.gitignore` with sensible defaults (node_modules, .env, .DS_Store, __pycache__, *.pyc, dist/, build/, .cache/, *.log), and commit: `titan(init): initialize repository`
- If no: print "⚠ Proceeding without git. Version control is strongly recommended." and continue.

### Step 3: Detect Greenfield vs Brownfield

Scan the current directory for source files. Check for the presence of:
- Any files matching: `*.js`, `*.ts`, `*.py`, `*.go`, `*.rs`, `*.java`, `*.rb`, `*.swift`, `*.kt`, `*.c`, `*.cpp`, `*.cs`, `*.php`
- Any `package.json`, `Cargo.toml`, `go.mod`, `requirements.txt`, `Gemfile`, `build.gradle`, `pom.xml`, `*.csproj`, `Makefile`, `CMakeLists.txt`

**If source files found (brownfield):**
```
◆ Existing codebase detected.

  Found: [list top-level languages/frameworks detected]
  Files: ~[approximate count] source files

  ⚠ For brownfield projects, it is strongly recommended to run
    /titan:scan after initialization to build a comprehensive
    understanding of the existing codebase.
```
- Set `project_type: brownfield` in config.

**If NO source files found (greenfield):**
```
◆ Greenfield project — starting fresh.
```
- Set `project_type: greenfield` in config.

### Step 4: Domain Selection

Ask the user to select their project domain:

```
What type of project are you building?

  1. web            — Web application (React, Vue, Next.js, etc.)
  2. mobile         — Mobile app (iOS, Android, React Native, Flutter)
  3. desktop        — Desktop application (Electron, Tauri, native)
  4. audio          — Audio software (plugins, DAWs, DSP)
  5. game           — Game development (Unity, Godot, custom engine)
  6. data           — Data pipelines, analytics, ML/AI
  7. api            — API / backend service
  8. infrastructure — Infrastructure as code, DevOps, platform
  9. general        — Not sure yet / mixed / other

Enter number or name:
```

Wait for the user's response. Map their answer to the domain key (e.g., "1" or "web" both map to `web`). If they answer "9" or "general", set domain to `general` and note that they can change it later with `/titan:settings`.

Store the selected domain as `domain` in config.

### Step 5: Model Profile Selection

Ask the user about their preferred quality/cost trade-off:

```
Select a model profile:

  1. quality    — Maximum quality, higher cost (Opus for everything)
  2. balanced   — Good balance of quality and cost (default)
  3. budget     — Cost-effective (Sonnet/Haiku)

Enter number or name [2]:
```

Default to `balanced` if the user just presses enter or says "default". Store as `profile` in config.

### Step 6: Create .titan/ Directory Structure

Create the following directory tree:

```
.titan/
├── phases/
├── quick/
├── investigations/
├── experiments/
├── research/
├── knowledge/
├── shards/
├── debug/
└── handoffs/
```

Use `mkdir -p` to create all directories in a single operation.

### Step 7: Generate config.yaml

Write `.titan/config.yaml` with the following content (substitute actual values):

```yaml
# TITAN Configuration
# Generated: [ISO 8601 timestamp]

project:
  name: [directory name, cleaned up as a readable project name]
  type: [greenfield|brownfield]
  domain: [selected domain]
  initialized: [ISO 8601 timestamp]

profile: [quality|balanced|budget]

profiles:
  quality:
    planning: claude-opus-4-6
    execution: claude-opus-4-6
    review: claude-opus-4-6
  balanced:
    planning: claude-opus-4-6
    execution: claude-sonnet-4-6
    review: claude-sonnet-4-6
  budget:
    planning: claude-sonnet-4-6
    execution: claude-haiku-4-5
    review: claude-haiku-4-5

context:
  brackets:
    fresh: 70
    moderate: 40
    deep: 20
    critical: 10
  work_unit_target: 50
  max_tasks_per_plan: 3

git:
  commit_prefix: "titan"
  branch_prefix: "titan/"
  auto_commit: true

verification:
  mandatory: true
  adversarial: true
  min_issues: 1
```

### Step 8: Create STATE.md

Write `.titan/STATE.md`:

```markdown
# TITAN State

## Current Position
- Phase: 0 (Initialization)
- Step: init
- Status: active
- Last Action: Project initialized
- Updated: [ISO 8601 timestamp]

## Completed Phases
| Phase | Name | Status | Date |
|-------|------|--------|------|
| 00 | Initialization | ✓ Complete | [today's date] |

## Active Decisions
| # | Decision | Rationale | Date |
|---|----------|-----------|------|
| 1 | Domain: [domain] | User selection during init | [today] |
| 2 | Profile: [profile] | User selection during init | [today] |

## Deferred Items
| Item | Reason | Revisit |
|------|--------|---------|

## Blockers
| Blocker | Impact | Proposed Resolution |
|---------|--------|-------------------|

## Knowledge Snapshots
- Project initialized as [greenfield|brownfield] [domain] project

## Next Action
> Run `/titan:02-vision` to define the project vision, requirements, and architecture.
```

### Step 9: Create KNOWLEDGE.md

Write `.titan/KNOWLEDGE.md`:

```markdown
# TITAN Knowledge Base

> Accumulated project knowledge, patterns, and learnings.
> Updated automatically during verify phases and manually via /titan:learn.

## Project Facts
- Type: [greenfield|brownfield]
- Domain: [domain]
- Initialized: [date]

## Patterns Discovered
<!-- Populated during development -->

## Key Learnings
<!-- Populated during verify phases -->

## Technology Notes
<!-- Populated during explore phases -->
```

### Step 10: Create DECISIONS.md

Write `.titan/DECISIONS.md`:

```markdown
# TITAN Decision Log

> Every non-trivial decision with rationale. Future sessions consult this first.

| # | Date | Decision | Rationale | Revisitable? |
|---|------|----------|-----------|-------------|
| 1 | [today] | Domain: [domain] | User selection during initialization | Yes — /titan:settings |
| 2 | [today] | Profile: [profile] | User selection during initialization | Yes — /titan:settings |
```

### Step 11: Create CLAUDE.md

Write `CLAUDE.md` at the project root (NOT inside .titan/):

```markdown
# Project Intelligence — CLAUDE.md

> This file is loaded automatically by Claude Code at the start of every session.
> It contains critical project context, conventions, and rules.

## Project
- **Name:** [project name]
- **Domain:** [domain]
- **Type:** [greenfield|brownfield]
- **Framework:** TITAN

## TITAN State
- Read `.titan/STATE.md` for current project position
- Read `.titan/DECISIONS.md` before making architectural choices
- Read `.titan/KNOWLEDGE.md` for accumulated learnings

## Conventions
- **Commits:** `titan(phase-NN): description` — atomic, one per task
- **Branches:** `titan/phase-NN-name` — one per phase
- **Verification:** Mandatory after every build phase

## Commands
Run `/titan:help` for the complete command reference.
To continue from where you left off: `/titan:resume`

## Rules
- Never skip verification (/titan:07-verify)
- Always read PLAN.md before building
- Always update STATE.md after completing work
- Respect file boundaries defined in plans
- Document non-trivial decisions in DECISIONS.md
```

### Step 12: Create AGENTS.md

Write `AGENTS.md` at the project root (for OpenCode compatibility):

```markdown
# Project Intelligence — AGENTS.md

> This file is loaded automatically by OpenCode at the start of every session.
> It contains critical project context, conventions, and rules.
> Content mirrors CLAUDE.md — kept in sync for cross-tool compatibility.

## Project
- **Name:** [project name]
- **Domain:** [domain]
- **Type:** [greenfield|brownfield]
- **Framework:** TITAN

## TITAN State
- Read `.titan/STATE.md` for current project position
- Read `.titan/DECISIONS.md` before making architectural choices
- Read `.titan/KNOWLEDGE.md` for accumulated learnings

## Conventions
- **Commits:** `titan(phase-NN): description` — atomic, one per task
- **Branches:** `titan/phase-NN-name` — one per phase
- **Verification:** Mandatory after every build phase

## Commands
Run `/titan:help` for the complete command reference.
To continue from where you left off: `/titan:resume`

## Rules
- Never skip verification (/titan:07-verify)
- Always read PLAN.md before building
- Always update STATE.md after completing work
- Respect file boundaries defined in plans
- Document non-trivial decisions in DECISIONS.md
```

### Step 13: Display Completion Summary

Print:

```
╔══════════════════════════════════════════════════════════════╗
║  ✓ TITAN — INITIALIZATION COMPLETE                          ║
╚══════════════════════════════════════════════════════════════╝

  Project:  [project name]
  Domain:   [domain]
  Type:     [greenfield|brownfield]
  Profile:  [profile]

  Created:
    ✓ .titan/              Project state directory
    ✓ .titan/config.yaml   Configuration
    ✓ .titan/STATE.md      Project state tracker
    ✓ .titan/KNOWLEDGE.md  Knowledge base
    ✓ .titan/DECISIONS.md  Decision log
    ✓ CLAUDE.md            Claude Code project rules
    ✓ AGENTS.md            OpenCode project rules

  What's Next:
  ─────────────────────────────────────────────────
  Run /titan:02-vision to define your project's vision,
  requirements, architecture, and roadmap.

  [If brownfield]: First consider running /titan:scan
  to analyze your existing codebase.
  ─────────────────────────────────────────────────

  Phase 1 of 8 ▓▓░░░░░░░░░░░░░░ 12%
```

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| config.yaml | `.titan/config.yaml` | Project configuration |
| STATE.md | `.titan/STATE.md` | Project state tracker |
| KNOWLEDGE.md | `.titan/KNOWLEDGE.md` | Knowledge accumulation |
| DECISIONS.md | `.titan/DECISIONS.md` | Decision log |
| CLAUDE.md | `./CLAUDE.md` | Claude Code project rules |
| AGENTS.md | `./AGENTS.md` | OpenCode project rules |
| Directory tree | `.titan/*/` | All required subdirectories |

## State Updates

After this command completes, STATE.md should show:
- Phase: 0 (complete)
- Next Action: `/titan:02-vision`

## Error Handling

| Error | Resolution |
|-------|-----------|
| `.titan/` already exists | Inform user, suggest `/titan:resume` or manual deletion |
| No write permissions | Alert user about permission issues, suggest fixing |
| Git init fails | Continue without git, warn user |
| User cancels during prompts | Clean up any partially created files, exit gracefully |

## Tips

- If you are unsure about the domain, choose `general` — you can change it later with `/titan:settings`.
- For brownfield projects, `/titan:scan` before `/titan:02-vision` gives dramatically better results.
- The `balanced` profile is the right choice for 90% of projects. Only use `quality` for critical production systems or `budget` for quick experiments.

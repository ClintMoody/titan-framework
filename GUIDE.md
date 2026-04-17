# TITAN — Complete Reference Guide

> The definitive reference for every command, agent, template, and workflow in the TITAN framework.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [The Golden Path](#the-golden-path)
3. [Core Commands (01-09)](#core-commands)
4. [Power Tools](#power-tools)
5. [Session Management](#session-management)
6. [Agents](#agents)
7. [Domain Plugins](#domain-plugins)
8. [Templates & Artifacts](#templates--artifacts)
9. [Configuration](#configuration)
10. [Context Management](#context-management)
11. [Git Integration](#git-integration)
12. [Novel Problem Solving](#novel-problem-solving)
13. [Common Workflows](#common-workflows)
14. [Troubleshooting](#troubleshooting)

---

## Quick Start

### New Project (Greenfield)

```
/titan:01-init              ← Set up project structure
/titan:02-vision            ← Define what you're building
/titan:04-explore           ← Research unknowns (skip if straightforward)
/titan:05-design            ← Design the UI (skip if no UI)
/titan:06-plan              ← Plan the first phase
/titan:07-build             ← Build it
/titan:08-verify            ← Prove it works
/titan:09-ship              ← Release
```

### Existing Project (Brownfield)

```
/titan:01-init              ← Set up TITAN in existing project
/titan:scan              ← Analyze the codebase (4 parallel researchers)
/titan:02-vision            ← Define goals for this milestone
/titan:06-plan              ← Plan the first phase
/titan:07-build             ← Build it
/titan:08-verify            ← Prove it works
/titan:09-ship              ← Release
```

### Resuming Work

```
/titan:resume            ← Picks up where you left off
```

### Quick Fix

```
/titan:quick             ← Small task with full quality guarantees
```

### Stuck on Something Novel

```
/titan:investigate       ← Systematic problem analysis
/titan:experiment        ← Try multiple approaches
```

---

## The Golden Path

The Golden Path is TITAN's core workflow. 9 numbered steps, followed in order.

```
  01 INIT ──→ 02 VISION ──→ 03 BOOTSTRAP ──→ 04 EXPLORE ──→ 05 DESIGN
                                                                  │
  09 SHIP ←── 08 VERIFY ←── 07 BUILD ←──────────────────── 06 PLAN
                  │                                          │
                  └──────────── repeat 06→08 ────────────────┘
                                for each phase
```

**Steps 01-05** run once per project (or milestone).
**Steps 06-08** repeat for each phase in your roadmap.
**Step 09** runs once per milestone to ship.

### When to Skip Steps

| Step | Skip When |
|------|-----------|
| 03 Bootstrap | Not using autonomous loop — manual phase-by-phase with plan/build/verify |
| 04 Explore | Technology stack is well-known, no unknowns |
| 05 Design | Project has no UI (API, library, CLI, infrastructure) |

Never skip: 01 Init, 02 Vision, 06 Plan, 07 Build, 08 Verify, 09 Ship.

---

## Core Commands

### /titan:01-init — Initialize Project

**When:** Starting a new project or adding TITAN to an existing one.

**What it does:**
1. Detects greenfield vs. brownfield (existing source files)
2. Creates `.titan/` directory with all subdirectories
3. Asks about your domain (web, mobile, audio, etc.)
4. Generates `config.yaml` with smart defaults
5. Creates `CLAUDE.md` at project root
6. Initializes `STATE.md`
7. Initializes git repo if needed

**Produces:** `.titan/` directory, `config.yaml`, `STATE.md`, `CLAUDE.md`

**Next step:** `/titan:02-vision` (or `/titan:scan` first if brownfield)

---

### /titan:02-vision — Define Your Product

**When:** After init. Defines the complete product vision.

**What it does:**
1. Three AI personas interview you progressively:
   - **Visionary Analyst** — Big picture, problem, users, market
   - **Product Strategist** — Requirements, priorities, constraints, success criteria
   - **Technical Architect** — System design, technology choices, components
2. Each persona asks follow-up questions for depth
3. Generates four artifacts from the interviews

**Produces:**
- `PROJECT.md` — Vision, scope, constraints, target users
- `REQUIREMENTS.md` — Functional + non-functional, each with BDD acceptance criteria
- `ARCHITECTURE.md` — System design, components, patterns, tech choices
- `ROADMAP.md` — Phase breakdown with milestones

**Next step:** `/titan:04-explore` (if unknowns) or `/titan:05-design` (if UI) or `/titan:06-plan`

---

### /titan:04-explore — Research the Unknown

**When:** Before planning, when there are things you don't fully understand.

**What it does:**
1. Identifies what needs research (technologies, patterns, approaches)
2. Searches for prior art and best practices
3. Evaluates alternatives with pros/cons
4. Documents findings and recommendations
5. Updates knowledge base

**Produces:** `EXPLORATION.md` in the current phase directory, updates to `KNOWLEDGE.md`

**Next step:** `/titan:05-design` (if UI) or `/titan:06-plan`

---

### /titan:05-design — Design the UI/UX

**When:** Your project has a user interface.

**What it does:**
1. Conversational interview about UI needs
2. Delegates to `titan-designer` agent for HTML mockups
3. You review mockups in your browser
4. Iterate until you approve
5. Generates design specification

**Produces:** `design/BRIEF.md`, `design/SPEC.md`, HTML mockups in `mockups/`

**Skip if:** API-only, library, CLI tool, infrastructure

**Next step:** `/titan:06-plan`

---

### /titan:06-plan — Create Execution Plan

**When:** Starting a new phase. Run for each phase in your roadmap.

**What it does:**
1. Spawns `titan-researcher` to analyze codebase
2. Creates detailed task list with:
   - Mode: agent (parallel) or in-session (sequential)
   - Files to modify, boundaries (files to NOT touch)
   - Acceptance criteria and verification steps
3. Organizes tasks into execution waves
4. Validates plan against checklist
5. Presents for your approval

**Produces:** `PLAN.md` in the current phase directory

**Next step:** `/titan:07-build`

---

### /titan:07-build — Execute the Plan

**When:** After plan is approved.

**What it does:**
1. Creates git branch for the phase
2. Executes tasks in wave order:
   - Agent tasks: spawns `titan-executor` agents in parallel
   - In-session tasks: executes directly
3. One atomic git commit per task
4. Reports progress after each task
5. Handles failures (retry once, then mark blocked)

**Produces:** Working code, atomic git commits, progress updates

**Next step:** `/titan:08-verify`

---

### /titan:08-verify — Prove It Works (MANDATORY)

**When:** After build completes. Cannot be skipped.

**What it does (3 parts):**

**Part 1 — Reconciliation:**
- Compares plan vs. actual (DONE, DONE-MODIFIED, DEFERRED, FAILED, ADDED)
- Passes/fails each acceptance criterion with evidence
- Verifies state consistency

**Part 2 — Two-Stage Adversarial Review:**
- **Stage A (Spec Compliance):** Spawns `titan-verifier` in Mode A — verifies the code matches the specification. If Stage A fails with critical issues, Stage B is skipped.
- **Stage B (Code Quality):** Spawns a second `titan-verifier` in Mode B — reviews code quality, security, domain-specific concerns, and test coverage.
- Separate agents with separate prompts catch well-written-but-wrong code that single-pass review misses.
- Each stage must find at least 1 genuine issue (no rubber-stamping).

**Part 3 — Knowledge Capture:**
- Records what worked, what was learned
- Updates `KNOWLEDGE.md` and `DECISIONS.md`

**Produces:** `SUMMARY.md`, `EVALUATION.md`, knowledge updates

**If FAIL:** Fix issues, return to `/titan:07-build`
**If PASS:** `/titan:06-plan` (next phase) or `/titan:09-ship` (if milestone complete)

---

### /titan:09-ship — Release

**When:** All phases for the milestone are verified.

**What it does:**
1. Pre-flight checklist (all phases verified, no blockers, clean tree)
2. Generates release summary
3. Merges branches, creates git tag
4. Archives phase data
5. Celebration banner with metrics

**Produces:** Git tag, release summary, archived phases

**Next step:** New milestone or deploy

---

## Power Tools

### /titan:scan — Codebase Analysis

Spawns 4 parallel researchers to analyze an existing codebase:
1. **Stack** — Languages, frameworks, dependencies, build system
2. **Architecture** — File organization, components, data flow
3. **Conventions** — Naming, formatting, patterns, testing
4. **Concerns** — Tech debt, security issues, performance bottlenecks

**Produces:** `.titan/research/SUMMARY.md` + per-focus reports

---

### /titan:quick — Small Task, Full Rigor

For tasks that don't warrant a full phase but still deserve quality. Mini-plan → execute → reconcile in one step. Supports decimal phases (3.1, 3.2) for interrupt work.

**Produces:** `.titan/quick/NNN-slug/` with plan and summary

---

### /titan:debug — Scientific Debugging

Systematic debugging using the scientific method:
1. Observe symptoms
2. Form hypotheses (minimum 2)
3. Design and run experiments
4. Analyze results
5. Iterate or conclude

Persistent state survives `/clear` commands.

---

### /titan:investigate — Novel Problem Solving

TITAN's key differentiator. For problems nobody has solved before:
1. Articulate what's unknown
2. Research prior art extensively
3. Generate minimum 3 hypotheses
4. Define evaluation criteria
5. Recommend with full rationale

**Produces:** `.titan/investigations/NNN-slug/INVESTIGATION.md`

---

### /titan:experiment — Try Multiple Approaches

When investigation identifies candidates, test them:
1. Define experiment with success criteria
2. Create isolation (branch/worktree)
3. Build minimal prototype
4. Measure results
5. Compare and decide: keep, modify, or discard

**Produces:** `.titan/experiments/NNN-slug/EXPERIMENT.md`

---

### /titan:learn — Deep Research

Study a technology, pattern, or concept before using it:
1. Research authoritative sources
2. Extract key concepts
3. Find code examples
4. Identify pitfalls
5. Apply to current project

**Produces:** `.titan/knowledge/[topic].md`, updates `KNOWLEDGE.md`

---

### /titan:review — On-Demand Code Review

Adversarial code review anytime, not just during verify. Targets specific files or a branch diff.

**Produces:** Review report with critical/important/minor findings

---

### /titan:test — Test Generation & TDD

Two modes:
- **Generate:** Analyze code, generate comprehensive tests
- **TDD:** RED → GREEN → REFACTOR cycle

Spawns `titan-tester` agent. Behavior-focused tests (what, not how).

---

### /titan:audit — Comprehensive Audit

Parallel audits across dimensions:
- Security (OWASP Top 10, dependency vulnerabilities, secrets)
- Performance (bottlenecks, memory, bundle size)
- Domain-specific (from loaded plugin)
- Accessibility (if applicable)

**Produces:** `AUDIT.md` with findings and remediation

---

### /titan:refactor — Safe Refactoring

Refactor with confidence:
1. Ensure tests exist (generate if needed)
2. Plan minimal changes
3. Execute with test verification after each step
4. Full test suite on completion

Tests must pass before AND after every change.

---

## Power Tools (v2.2 Additions)

### /titan:capture — Background Capture

Capture a stray thought without interrupting your flow. Appends a timestamped note to `.titan/captures.md` and prints "Captured." -- nothing else.

```
/titan:capture We should add rate limiting before launch
```

Captures are triaged automatically during `/titan:06-plan` (Step 3b). Relevant captures become tasks or risks in the plan.

---

## Session Management

### /titan:resume — Continue Previous Work

Reads handoff documents and state, suggests exactly one next action.

### /titan:pause — Save and Stop

Updates state, creates HANDOFF.md with full narrative, commits WIP.

### /titan:progress — Status Dashboard

Clean display of current phase, tasks, blockers, recent decisions, next action.

### /titan:autopilot — Supervised Autonomous Mode

Runs plan-build-verify for each remaining phase with human checkpoints between phases. Pauses for review after each phase completes. Stops gracefully at 60% context or on rate limits.

### /titan:autopilot-full — Full Autonomous Mode

Walk-away execution. Runs plan-build-verify for all remaining phases without human intervention. Self-chains across context windows by spawning successors. Terminates on completion, human-needed blockers, stuck loops, or verification failures requiring architecture decisions.

### /titan:settings — Configuration

Interactive menu for model profiles, domain, execution preferences, git settings.

### /titan:help — Command Reference

Quick reference for all 24 commands with common workflows.

---

## Agents

TITAN deploys 9 specialized agents, each in a fresh context window.

| Agent | Role | Default Model | Spawned By |
|-------|------|--------------|------------|
| **titan-executor** | Implements tasks from plans | sonnet | /titan:07-build |
| **titan-verifier** | Adversarial code review | sonnet (opus for complex) | /titan:08-verify, /titan:review |
| **titan-researcher** | Codebase analysis | sonnet | /titan:06-plan, /titan:scan |
| **titan-designer** | HTML/CSS mockup generation | sonnet | /titan:05-design |
| **titan-investigator** | Novel problem research | sonnet (opus for novel) | /titan:investigate |
| **titan-strategist** | Architecture evaluation | opus | /titan:04-explore, /titan:02-vision |
| **titan-security** | Vulnerability detection | sonnet | /titan:audit |
| **titan-optimizer** | Performance analysis | sonnet | /titan:audit |
| **titan-tester** | Test generation | sonnet | /titan:test, /titan:refactor |

### Universal Agent Rules
- Fresh context window per spawn (no inherited state)
- Read first, act second
- Follow plan literally — no improvisation
- Report blockers immediately
- Respect file boundaries
- Domain plugins modify behavior

---

## Domain Plugins

Configure your domain in `config.yaml`:

```yaml
domain:
  primary: web
```

### Available Domains

| Domain | Key Focus Areas |
|--------|----------------|
| **web** | Accessibility, SEO, responsive design, Core Web Vitals, CSP |
| **mobile** | Battery efficiency, offline-first, permissions, app store compliance |
| **desktop** | Native integration, system resources, cross-platform, installers |
| **audio** | Real-time safety, denormal protection, buffer management, thread safety |
| **game** | Frame rate, physics, asset pipeline, input latency, memory management |
| **data** | Pipeline reliability, schema evolution, idempotency, monitoring |
| **api** | REST/GraphQL standards, versioning, rate limiting, documentation |
| **infrastructure** | IaC best practices, security, cost optimization, observability |

### What Domain Plugins Customize

- **Verifier checks** — Domain-specific quality criteria
- **Researcher focus** — What to look for when analyzing codebases
- **Quality gates** — What must pass before shipping
- **Patterns** — Recommended approaches for this domain
- **Anti-patterns** — What to avoid

### Creating Custom Domains

Add a YAML file to `.titan/domains/` (or the templates directory):

```yaml
name: Your Domain
description: What this domain covers

verifier_checks:
  - Check 1
  - Check 2

researcher_focus:
  - Focus area 1
  - Focus area 2

quality_gates:
  - Gate 1
  - Gate 2

patterns:
  - Pattern 1
  - Pattern 2

anti_patterns:
  - Anti-pattern 1
  - Anti-pattern 2
```

---

## Templates & Artifacts

### Project Artifacts (Created by TITAN)

| File | Created By | Purpose |
|------|-----------|---------|
| `config.yaml` | /titan:01-init | Project configuration |
| `STATE.md` | /titan:01-init | Current position (source of truth) |
| `PROJECT.md` | /titan:02-vision | Vision, scope, constraints |
| `REQUIREMENTS.md` | /titan:02-vision | Requirements with BDD acceptance criteria |
| `ARCHITECTURE.md` | /titan:02-vision | System design and technology choices |
| `ROADMAP.md` | /titan:02-vision | Phase breakdown with milestones |
| `KNOWLEDGE.md` | /titan:08-verify | Accumulated project learnings |
| `DECISIONS.md` | /titan:08-verify | Decision log with rationale |
| `PLAN.md` | /titan:06-plan | Per-phase execution plan |
| `EXPLORATION.md` | /titan:04-explore | Research findings |
| `SUMMARY.md` | /titan:08-verify | Per-phase reconciliation report |
| `EVALUATION.md` | /titan:08-verify | Per-phase adversarial review |
| `INVESTIGATION.md` | /titan:investigate | Novel problem analysis |
| `EXPERIMENT.md` | /titan:experiment | Experiment results |
| `AUDIT.md` | /titan:audit | Security/performance audit |
| `HANDOFF.md` | /titan:pause | Session handoff (temporary) |

---

## Configuration

### config.yaml Structure

```yaml
# Project
project:
  name: "My Project"
  type: "web"           # web, mobile, desktop, audio, game, data, api, infrastructure
  version: "0.1.0"

# Domain expertise
domain:
  primary: web
  plugins: []           # Additional domain plugins

# Model profiles (which AI model for each role)
profiles:
  quality:              # Maximum quality
    planning: claude-opus-4-6
    execution: claude-opus-4-6
    review: claude-opus-4-6
  balanced:             # Default — good balance
    planning: claude-opus-4-6
    execution: claude-sonnet-4-6
    review: claude-sonnet-4-6
  budget:               # Cost-effective
    planning: claude-sonnet-4-6
    execution: claude-haiku-4-5
    review: claude-haiku-4-5

# Active profile
active_profile: balanced

# Execution preferences
execution:
  prefer_in_session:    # Task types to run in main session
    - integration
    - safety-critical
    - refactoring
  prefer_agent:         # Task types to delegate to agents
    - ui
    - tests
    - documentation
    - scaffolding

# Git conventions
git:
  atomic_commits: true
  auto_branch: true
  branch_pattern: "titan/phase-{NN}-{name}"
  commit_format: "titan(phase-{NN}): {description}"

# Reconciliation
reconciliation:
  mandatory: true       # Cannot skip /titan:08-verify
  state_consistency_check: true

# Context management
context:
  target_per_plan: 50   # % of context to target per plan
  max_tasks_per_plan: 3
  auto_shard_threshold: 500  # Lines before auto-sharding

# TDD
tdd:
  enabled: false
  context_target: 40    # % of context for TDD plans

# Autopilot
autopilot:
  pause_on_checkpoints: true
  fresh_context_per_step: true
```

---

## Context Management

### Context Brackets

TITAN monitors context usage and adapts behavior:

| Bracket | Remaining | Behavior |
|---------|-----------|----------|
| **FRESH** | >70% | Full exploration, consider multiple approaches |
| **MODERATE** | 40-70% | Focus on best approach, execute efficiently |
| **DEEP** | 20-40% | Essential operations only, prepare to wrap |
| **CRITICAL** | <20% | Stop immediately, save state, create handoff |

### Work Unit Sizing

- Target: 50% of context per plan
- Maximum: 2-3 tasks per plan
- If more work needed: split into sub-phases

### Document Sharding

Documents exceeding the auto-shard threshold (default: 500 lines) are automatically split into focused chunks, saving ~90% of tokens when only a portion is needed.

---

## Git Integration

### Branch Strategy

```
main (or master)
  └── titan/phase-01-setup
  └── titan/phase-02-core-features
  └── titan/phase-03-polish
  └── titan/phase-03.1-hotfix
```

### Commit Format

```
titan(phase-01): implement user authentication
titan(phase-01): add login form validation
titan(phase-02): create product listing API
titan(quick-001): fix navigation hover state
```

### Rules

- One commit per task (atomic, bisectable)
- Auto-branch per phase
- No force-push, ever
- Tags on ship: `vX.Y.Z` with annotated release notes

---

## Novel Problem Solving

TITAN's signature capability. When you encounter something nobody has solved before:

### The Investigation Loop

```
PROBLEM → RESEARCH → HYPOTHESIZE → EXPERIMENT → EVALUATE → DECIDE
    ↑                                                          |
    └──────────── (iterate if no good solution) ───────────────┘
```

### Step-by-Step

1. **Run `/titan:investigate`** — Articulate the problem, research prior art, generate minimum 3 hypotheses, define evaluation criteria, get a recommendation.

2. **If confident:** Proceed to `/titan:06-plan` with the recommended approach.

3. **If uncertain:** Run `/titan:experiment` — Build minimal prototypes for top 2-3 approaches, measure results, compare, pick the winner.

4. **Document everything** — Investigation and experiment records persist in `.titan/`, building project knowledge.

### When to Use

- Technology evaluation (React vs. Svelte vs. Solid)
- Architecture decisions (monolith vs. microservices)
- Algorithm selection (which sorting/searching/matching approach)
- Integration challenges (combining unfamiliar APIs or systems)
- Performance optimization (which bottleneck to address, how)
- Any problem where you think "I'm not sure how to approach this"

---

## Common Workflows

### Starting Fresh

```
/titan:01-init → /titan:02-vision → /titan:04-explore → /titan:05-design → /titan:06-plan → /titan:07-build → /titan:08-verify → /titan:09-ship
```

### Adding a Feature to Existing Project

```
/titan:01-init (if TITAN not set up) → /titan:scan → /titan:06-plan → /titan:07-build → /titan:08-verify
```

### Debugging a Production Issue

```
/titan:debug
```

### Quick Fix or Small Enhancement

```
/titan:quick
```

### Researching Before Implementing

```
/titan:learn (for a technology)
/titan:investigate (for a problem)
/titan:experiment (to compare approaches)
```

### Resuming After a Break

```
/titan:resume
```

### End-to-End Automated

```
/titan:autopilot
```

### Security/Performance Review

```
/titan:audit
```

### Safe Refactoring

```
/titan:refactor
```

---

## Troubleshooting

### "STATE.md is inconsistent"

Run `/titan:progress` to see current state. If needed, manually update `.titan/STATE.md` to reflect reality.

### "Verify found critical issues"

This is working as intended. Fix the issues flagged in `EVALUATION.md`, then run `/titan:07-build` to implement fixes, then `/titan:08-verify` again.

### "Context is running low"

TITAN's context brackets handle this. When you hit DEEP or CRITICAL, the framework will guide you to save state and start fresh.

### "Agent task failed"

Check the agent's output for error details. The build orchestrator retries once, then marks as BLOCKED. You can either fix the issue and re-run, or modify the plan.

### "I don't know which command to use"

Run `/titan:help` for the full reference, or `/titan:progress` to see what's next based on current state.

### "Plan is too large"

The planner auto-splits work that exceeds 50% context or 3 tasks. If it doesn't, you can manually break phases into sub-phases using decimal numbering (3.1, 3.2).

---

## Visual Reference

### Stage Banners

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — INITIALIZING                                     ║
╚══════════════════════════════════════════════════════════════╝
```

### Status Symbols

| Symbol | Meaning |
|--------|---------|
| ✓ | Complete |
| ✗ | Failed |
| ◆ | In Progress |
| ○ | Pending |
| ⚡ | Active/Current |
| ⚠ | Warning |
| ★ | Milestone |

### Progress Bar

```
Phase 3 of 9 ▓▓▓▓▓░░░░░░░░░░░ 33%
```

---

*TITAN — One person. World-class software. Every time.*

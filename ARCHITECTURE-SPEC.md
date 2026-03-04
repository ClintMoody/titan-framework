# TITAN Architecture Specification (Internal Reference)

> This document defines the complete TITAN framework architecture.
> All commands, agents, and templates MUST be consistent with this spec.

---

## Identity

**Name:** TITAN
**Tagline:** The complete software development framework for building world-class products.
**Philosophy:** One person, armed with TITAN, can build software that competes with teams of hundreds.

TITAN is NOT an acronym. It's a name that conveys extraordinary power and influence.

---

## Who TITAN Is For

The solo developer — from complete beginner to seasoned expert — who wants to:
- Build world-class software systematically
- Handle novel, never-before-encountered problems with confidence
- Ship fast without sacrificing quality
- Make decisions with clarity, not guesswork

TITAN treats every developer as capable. It guides without condescending. It teaches through doing.

---

## Origin

TITAN is a fork of the FORGE framework, which synthesized:
- **PAUL** (Plan-Apply-Unify Loop): Mandatory reconciliation, acceptance-driven BDD, context brackets
- **GSD** (Get Shit Done): Thin orchestrator, fresh-context subagents, parallel execution
- **BMAD** (Breakthrough Method for Agile Development): Persona-driven planning, progressive artifacts, adversarial review

TITAN takes FORGE's 9.1/10 foundation and evolves it into a fully general-purpose, domain-agnostic, novel-problem-solving powerhouse.

---

## Core Philosophy: 7 Principles

### 1. The Golden Path is Simple
8 numbered steps: init → vision → explore → design → plan → build → verify → ship.
Anyone can follow 1, 2, 3, 4, 5, 6, 7, 8. Repeat 5-7 for each phase.

### 2. Novel Problems Deserve Systematic Treatment
When you encounter something you've never seen before, you don't panic — you investigate, hypothesize, experiment, and evaluate. TITAN has dedicated workflows for this.

### 3. Quality is Non-Negotiable
Every phase must pass verification. No orphan plans. No unproven code. Mandatory reconciliation means you always know what was actually built vs. what was planned.

### 4. Context is Precious
Fresh-context subagents get clean 200k windows. Work units target 50% context. Document sharding saves 90% tokens on large docs. Context brackets adapt behavior as windows fill.

### 5. Decisions Are Documented
Every non-trivial decision gets recorded with rationale. Future-you (or future-AI) can understand WHY, not just WHAT.

### 6. Domain Expertise is Pluggable
No hardcoded domain assumptions. Web, mobile, desktop, audio, game, data, API, infrastructure — each loads specific quality checks, patterns, and guardrails.

### 7. Speed Comes From Doing It Right
Parallel execution, fresh-context agents, wave-based task distribution — these make TITAN fast. But the real speed comes from never having to redo work because verification caught issues early.

---

## The Golden Path (Core Workflow)

```
01-INIT → 02-VISION → 03-EXPLORE → 04-DESIGN → 05-PLAN → 06-BUILD → 07-VERIFY → 08-SHIP
                                                   ↑________________________↩ (repeat per phase)
```

| # | Command | Phase | What It Does |
|---|---------|-------|-------------|
| 01 | `/titan:init` | Setup | Scaffold `.titan/`, detect brownfield/greenfield, configure domain |
| 02 | `/titan:vision` | Define | Progressive persona chain → PROJECT.md, REQUIREMENTS.md, ARCHITECTURE.md, ROADMAP.md |
| 03 | `/titan:explore` | Discover | Deep research, prior art, technology evaluation, novel problem mapping |
| 04 | `/titan:design` | Design | Conversational UI/UX → iterative HTML mockups → approved specs |
| 05 | `/titan:plan` | Plan | Researcher agent → execution plan with waves, ACs, boundaries |
| 06 | `/titan:build` | Execute | Thin orchestrator → parallel executor agents + in-session work |
| 07 | `/titan:verify` | Prove | Reconciliation + adversarial review + knowledge capture (MANDATORY) |
| 08 | `/titan:ship` | Release | Pre-flight → merge → tag → release notes → celebrate |

---

## Power Tools (24 total commands)

### Power Tools (use anytime)
| Command | Purpose |
|---------|---------|
| `/titan:scan` | Deep codebase analysis with 4 parallel researchers |
| `/titan:quick` | Small task with full quality guarantees |
| `/titan:debug` | Scientific debugging with hypothesis tracking |
| `/titan:investigate` | **Novel problem solving** — systematic approach to unknowns |
| `/titan:experiment` | **Try multiple approaches** — isolated prototyping + comparison |
| `/titan:learn` | **Research a technology** — study before using |
| `/titan:review` | On-demand adversarial code review |
| `/titan:test` | Test generation and TDD workflows |
| `/titan:audit` | Security + performance + accessibility + domain audit |
| `/titan:refactor` | Safe refactoring with test preservation |

### Session Management
| Command | Purpose |
|---------|---------|
| `/titan:resume` | Continue from previous session with full context |
| `/titan:pause` | Save state and create handoff document |
| `/titan:progress` | Project status dashboard |
| `/titan:autopilot` | Auto-run phases with fresh context per step |
| `/titan:settings` | Configure model profiles, domain, preferences |
| `/titan:help` | Complete command reference |

---

## Agent Architecture (9 Agents)

### Core Agents (from FORGE, enhanced)
1. **titan-executor** — Implements tasks from PLAN.md. One task = one atomic commit. Domain-aware.
2. **titan-verifier** — Adversarial code reviewer. Pluggable domain expertise. Must find ≥1 issue.
3. **titan-researcher** — Pre-planning codebase analysis. Domain-aware focus areas.
4. **titan-designer** — Generates browser-testable HTML mockups from design briefs.

### New Agents
5. **titan-investigator** — Novel problem analysis. Hypothesis generation + evaluation. The "scientist."
6. **titan-strategist** — High-level architecture evaluation. Approach comparison. The "advisor."
7. **titan-security** — Security vulnerability detection across OWASP Top 10 + supply chain + secrets.
8. **titan-optimizer** — Performance analysis, bottleneck identification, optimization recommendations.
9. **titan-tester** — Test generation, TDD support, edge case discovery, coverage analysis.

### Agent Rules (Universal)
- Fresh 200k context window per spawn
- Read first, act second
- Follow plan literally — no improvisation
- Report blockers immediately
- Respect file boundaries
- Domain plugins modify checks/focus areas

---

## Domain Plugin System

### Structure
```yaml
# domains/web.yaml
name: Web Application
description: Standards for modern web applications

verifier_checks:
  - Accessibility (WCAG 2.1 AA)
  - SEO fundamentals
  - Responsive design (mobile-first)
  - Core Web Vitals awareness
  - CSP and security headers
  - Progressive enhancement

researcher_focus:
  - Framework conventions and patterns
  - Bundle size and tree-shaking
  - SSR/SSG considerations
  - API integration patterns

quality_gates:
  - No accessibility violations (critical)
  - No XSS vulnerabilities
  - Mobile-responsive
  - Semantic HTML

patterns:
  - Component composition
  - State management (local vs global)
  - Error boundaries
  - Loading states and optimistic UI

anti_patterns:
  - Prop drilling beyond 3 levels
  - Direct DOM manipulation in component frameworks
  - Synchronous blocking operations
  - Uncontrolled re-renders
```

### Available Domains
- **web** — Modern web applications
- **mobile** — iOS/Android/cross-platform
- **desktop** — Native desktop applications
- **audio** — Real-time audio/DSP (from FORGE's expertise)
- **game** — Game development
- **data** — Data pipelines and analytics
- **api** — APIs and backend services
- **infrastructure** — Infrastructure as code, DevOps

---

## Project Structure (Created by `/titan:init`)

```
project-root/
├── .titan/
│   ├── PROJECT.md              # Vision, scope, constraints
│   ├── REQUIREMENTS.md         # Functional/non-functional with BDD ACs
│   ├── ARCHITECTURE.md         # System design, components, patterns
│   ├── ROADMAP.md              # Phase breakdown with milestones
│   ├── STATE.md                # Current position — THE source of truth
│   ├── KNOWLEDGE.md            # Accumulated project knowledge
│   ├── DECISIONS.md            # Decision log with rationale
│   ├── config.yaml             # Configuration (domain, profiles, preferences)
│   ├── phases/
│   │   ├── 01-phase-name/
│   │   │   ├── PLAN.md         # Execution plan
│   │   │   ├── EXPLORATION.md  # Research findings (from /titan:explore)
│   │   │   ├── SUMMARY.md      # Post-verify reconciliation
│   │   │   ├── EVALUATION.md   # Post-verify adversarial review
│   │   │   └── ...
│   │   ├── 02-phase-name/
│   │   └── 02.1-urgent-fix/    # Decimal phase for interrupts
│   ├── quick/                  # Quick task records
│   ├── investigations/         # Novel problem investigations
│   ├── experiments/            # Experiment records
│   ├── research/               # Codebase scan results
│   ├── knowledge/              # Topic-specific knowledge files
│   ├── shards/                 # Auto-sharded large documents
│   ├── debug/                  # Debug session records
│   └── handoffs/               # Session handoff documents
├── CLAUDE.md                   # Project rules (Claude Code)
├── AGENTS.md                   # Project rules (OpenCode)
└── mockups/                    # Approved design mockups
```

---

## State Management

### STATE.md (Always Current)
```markdown
# TITAN State

## Current Position
- Phase: [number]
- Step: [plan|build|verify]
- Status: [active|paused|blocked]
- Last Action: [description]
- Updated: [ISO timestamp]

## Completed Phases
| Phase | Name | Status | Date |
|-------|------|--------|------|

## Active Decisions
| # | Decision | Rationale | Date |
|---|----------|-----------|------|

## Deferred Items
| Item | Reason | Revisit |
|------|--------|---------|

## Blockers
| Blocker | Impact | Proposed Resolution |
|---------|--------|-------------------|

## Knowledge Snapshots
- [Key learnings from recent work]

## Next Action
> [Exactly one clear next step]
```

### 2-Level Handoff System
- **Level 1: STATE.md** — Always maintained. Quick status. Same-day resumes.
- **Level 2: HANDOFF.md** — Created on pause. Full narrative. Multi-day gaps. Deleted after reading.

---

## Context Management

### Context Brackets
| Bracket | Context Remaining | Behavior |
|---------|------------------|----------|
| FRESH | >70% | Full exploration, multiple approaches |
| MODERATE | 40-70% | Focused execution, single best approach |
| DEEP | 20-40% | Essential operations only, prepare to wrap up |
| CRITICAL | <20% | Save state immediately, create handoff |

### Work Unit Sizing
- Target: 50% of context per plan
- Maximum: 2-3 tasks per plan
- Auto-shard documents >500 lines

---

## Git Integration

### Conventions
- **Commits:** `titan(phase-NN): description` — one commit per task, atomic
- **Branches:** `titan/phase-NN-name` — auto-created per phase
- **Tags:** `vX.Y.Z` — created on ship
- **No force-push.** Ever.

---

## Model Profiles

```yaml
profiles:
  quality:    # Maximum quality, higher cost
    planning: claude-opus-4-6
    execution: claude-opus-4-6
    review: claude-opus-4-6
  balanced:   # Good balance (default)
    planning: claude-opus-4-6
    execution: claude-sonnet-4-6
    review: claude-sonnet-4-6
  budget:     # Cost-effective
    planning: claude-sonnet-4-6
    execution: claude-haiku-4-5
    review: claude-haiku-4-5
```

---

## Visual Identity

### Stage Banners
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — [STAGE NAME]                                    ║
╚══════════════════════════════════════════════════════════════╝
```

### Status Symbols
- ✓ Complete
- ✗ Failed
- ◆ In Progress
- ○ Pending
- ⚡ Active/Current
- ⚠ Warning/Attention
- ★ Milestone

### Progress Format
```
Phase 3 of 8 ▓▓▓▓▓▓▓▓░░░░░░░░ 37%
```

---

## Command File Format (Consistent Structure)

```markdown
---
name: titan:command-name
description: One-line description for discovery
---

# /titan:command-name — Short Title

> When to use this command.

## Prerequisites
What must exist before running this command.

## Process
Step-by-step workflow (numbered, detailed, unambiguous).

## Outputs
Artifacts produced by this command.

## State Updates
How STATE.md changes after this command.

## Error Handling
What to do when things go wrong.

## Tips
Pro tips for getting the most out of this command.
```

---

## Agent File Format (Consistent Structure)

```markdown
---
name: titan-agent-name
description: One-line description
model: claude-sonnet-4-6
tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Titan Agent: Name

## Role
What this agent does and why it exists.

## When Spawned
What triggers creation of this agent.

## Inputs
What context the agent receives from the orchestrator.

## Process
Step-by-step workflow.

## Output Contract
What the agent MUST produce (structured format).

## Rules
Hard constraints and guardrails.

## Domain Awareness
How domain plugins modify this agent's behavior.
```

---

## Novel Problem Solving System (TITAN's Differentiator)

### The Investigation Loop
```
PROBLEM → RESEARCH → HYPOTHESIZE → EXPERIMENT → EVALUATE → DECIDE
    ↑                                                          |
    └──────────── (iterate if no solution found) ──────────────┘
```

### /titan:investigate
1. Problem articulation (what's unknown, what we know, what success looks like)
2. Prior art research (web search, docs, codebase, communities)
3. Hypothesis generation (minimum 3 distinct approaches)
4. Evaluation criteria definition (metrics, constraints, trade-offs)
5. Recommendation with rationale
6. Output: INVESTIGATION.md

### /titan:experiment
1. Experiment definition (hypothesis, success criteria, measurement plan)
2. Isolation (git branch or worktree)
3. Rapid prototyping
4. Measurement and analysis
5. Comparison against alternatives
6. Decision: keep, modify, or discard
7. Output: EXPERIMENT.md

This system ensures that even problems nobody has solved before get systematic, rigorous treatment.

---

## Key Differences from FORGE

| Aspect | FORGE | TITAN |
|--------|-------|-------|
| Domain | Audio-biased | General-purpose with pluggable domains |
| Novel Problems | No dedicated workflow | investigate + experiment commands |
| Agents | 4 | 9 (5 new specialists) |
| Learning | None | /titan:learn + knowledge accumulation |
| Verification | Separate reconcile + evaluate | Combined /titan:verify (both in one) |
| Exploration | None | /titan:explore as core step 03 |
| Audit | None | Security + performance + accessibility |
| Refactoring | None | Dedicated /titan:refactor |
| Commands | 24 | 24 (restructured: 8 core + 10 power + 6 session) |
| State | Sparse (6.5/10) | Rich with knowledge + decisions |

<p align="center">
  <img src=".github/banner.svg" alt="TITAN — The Complete Software Development Framework" width="900"/>
</p>

<p align="center">
  <strong>One person + TITAN = software that competes with teams of hundreds.</strong>
</p>

<p align="center">
  <a href="#installation"><img src="https://img.shields.io/badge/install-bash_install.sh-22C55E?style=flat-square&logo=gnu-bash&logoColor=white" alt="Install"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT_+_Commons_Clause-334155?style=flat-square" alt="MIT + Commons Clause"/></a>
  <img src="https://img.shields.io/badge/commands-24-22C55E?style=flat-square" alt="24 Commands"/>
  <img src="https://img.shields.io/badge/agents-9-334155?style=flat-square" alt="9 Agents"/>
  <img src="https://img.shields.io/badge/domains-8-22C55E?style=flat-square" alt="8 Domains"/>
  <img src="https://img.shields.io/badge/v2.1-GSD--2_integrated-F59E0B?style=flat-square" alt="v2.1"/>
</p>

---

## The Problem

You're one person. You have an idea. You want to build it *right* — not a prototype that falls apart, not a hack you'll rewrite in three months. You want software that works, that's verified, that you'd be proud to show anyone.

But the way AI-assisted development works today is: you prompt, you get code, you hope it's good. Nobody checks. Nobody tracks what was planned vs what was built. Nobody catches the bug that your tests don't cover. When your session crashes, you start over. When your budget runs out, you find out from your credit card statement.

TITAN fixes all of this.

---

## What TITAN Actually Does

TITAN is a development system that runs inside **Claude Code** (or **OpenCode**). You install it once, and it gives you 24 slash commands that manage your entire project lifecycle — from first idea to shipped release.

Here's what makes it different from "just prompting":

### It verifies everything. Twice.

After you build a phase, TITAN runs **two independent AI reviewers**. The first checks: *does this code do what the spec says?* The second checks: *is this code actually well-written?* Both reviewers have a **halt condition** — if they find zero issues, they're forced to look harder. No rubber-stamping.

Every acceptance criterion gets explicitly traced to code. Every deviation from the plan gets documented. "It probably works" is not an acceptable answer.

### It recovers from crashes.

Sessions crash. Laptops die. Claude Code hangs. Before v2.1, you'd lose your place and spend 20 minutes figuring out where you were.

Now TITAN writes a lock file during builds, tracks every committed task, and detects crashes automatically. When you come back, it tells you exactly which tasks finished, which one was in flight, and which haven't started. You type "continue" and pick up where you left off. Completed tasks never re-execute.

### It knows what things cost.

Every task logs its metrics. You see a running total in your dashboard — how much this phase cost, how much the milestone is projected to cost, and whether you're on track to blow your budget. If you set a ceiling, TITAN enforces it (warn, pause, or hard stop — your choice).

### It stops wasting expensive models on simple tasks.

TITAN classifies each task by complexity. A 2-file scaffolding task doesn't need Opus. A cross-module security migration does. Simple tasks automatically route to cheaper models. Complex tasks are protected — never downgraded. This cuts costs 40-60% with no quality loss where it matters.

### It catches errors immediately, not later.

Configure verification commands — `npm run lint`, `npm test`, `cargo check`, whatever your project uses — and TITAN runs them automatically after every single task. If lint fails, the executor tries to fix it before you even hear about it. Regressions surface in seconds, not during a manual review pass hours later.

### It learns from what it builds.

After each phase, TITAN reassesses the roadmap. Did we learn something that changes the plan for Phase 5? Did we discover a dependency we didn't know about? The roadmap adapts based on reality, not the assumptions you made on day one.

### It solves problems nobody has solved before.

Most AI tools assume you know what you're building. TITAN has dedicated workflows for when you don't. `/titan:investigate` gives you systematic hypothesis generation and evaluation. `/titan:experiment` lets you prototype approaches in isolation, measure them, and pick the winner. These aren't prompts — they're structured research processes that produce documented, evidence-based decisions.

---

## The Golden Path

8 steps. Follow them in order. Repeat 05-07 for each phase.

```
        01 INIT ──> 02 VISION ──> 03 EXPLORE ──> 04 DESIGN
                                                      |
        08 SHIP <── 07 VERIFY <── 06 BUILD <── 05 PLAN
                        |                        |
                        '──── repeat 05->07 ─────'
                              for each phase
```

| Step | Command | What Happens |
|:----:|---------|-------------|
| `01` | `/titan:01-init` | Scaffold the project. Detect greenfield or brownfield. Configure your domain. |
| `02` | `/titan:02-vision` | Three AI personas interview you — Visionary, Product Strategist, Technical Architect. You walk out with a vision doc, requirements with BDD acceptance criteria, a system architecture, and a phased roadmap. |
| `03` | `/titan:03-explore` | Research what you don't know. Prior art, technology evaluation, risk mapping. |
| `04` | `/titan:04-design` | Design your UI through conversation. Get real HTML/CSS mockups you can open in a browser and iterate on. |
| `05` | `/titan:05-plan` | A researcher agent scans your codebase, then TITAN builds a task-level execution plan with waves, boundaries, and acceptance criteria. |
| `06` | `/titan:06-build` | The thin orchestrator dispatches parallel agents — each in a fresh 200k-token context window. One task = one commit. Verification commands run after each task. Cost tracked per task. Crash recovery active. |
| `07` | `/titan:07-verify` | Mandatory 3-part gate: reconciliation (plan vs reality), two-stage adversarial review (spec + quality), and knowledge capture. Then reassess the roadmap based on what you learned. |
| `08` | `/titan:08-ship` | Pre-flight checklist. Merge branches. Tag release. Archive phase data. Cost report. Done. |

---

## 9 Specialized Agents

Each agent runs in a clean context window. No inherited fatigue. No accumulated garbage.

| Agent | What It Does |
|:------|:------------|
| **Executor** | Implements tasks from plans. Follows spec literally. One task = one atomic commit. Reports structured status (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED). |
| **Verifier** | Two-stage adversarial review. Stage A: does the code match the spec? Stage B: is the code well-written? Must find at least one issue per stage — no rubber-stamping. |
| **Researcher** | Scans your codebase before planning. Maps files, patterns, conventions, boundaries, risks. |
| **Designer** | Generates complete, browser-testable HTML/CSS mockups. Responsive. Accessible. Interactive states via CSS. |
| **Investigator** | Novel problem solver. Generates minimum 3 distinct hypotheses. Evaluates against criteria. Produces evidence-based recommendations. |
| **Strategist** | System-level architecture advisor. Evaluates approaches across scalability, performance, maintainability, complexity, and DX. |
| **Security** | OWASP Top 10. Supply chain. Secrets detection. Dangerous code patterns. Spawned proactively after risky changes. |
| **Optimizer** | Performance bottleneck analysis. Algorithmic complexity. Memory leaks. I/O patterns. Domain-specific (bundle size for web, frame budget for games, real-time safety for audio). |
| **Tester** | Test generation and TDD support. 60% happy path, 25% edge cases, 15% error paths. Framework-agnostic. |

---

## Domain-Aware Quality

TITAN doesn't treat a web app the same as an audio plugin. Configure your domain and quality checks adapt automatically.

```yaml
# .titan/config.yaml
domain:
  primary: web    # web | mobile | desktop | audio | game | data | api | infrastructure
```

Each domain defines what "quality" means for your kind of software:
- **Web**: accessibility (WCAG 2.1 AA), responsive design, XSS prevention, Core Web Vitals
- **Audio**: real-time safety, buffer management, denormal protection, latency budgets
- **Mobile**: battery impact, offline handling, platform guidelines
- **API**: input validation, rate limiting, auth patterns, error responses
- **Game**: frame budgets, memory management, input latency

8 domains ship with TITAN. Create your own with a single YAML file.

---

## Power Tools

Use these anytime, outside the Golden Path.

<table>
<tr>
<td width="50%" valign="top">

### Solve Hard Problems

| Command | Purpose |
|---------|---------|
| `/titan:investigate` | Systematic novel problem analysis |
| `/titan:experiment` | Isolated prototyping + comparison |
| `/titan:learn` | Deep research on any technology |
| `/titan:debug` | Scientific debugging with hypothesis tracking |

### Analyze & Improve

| Command | Purpose |
|---------|---------|
| `/titan:scan` | Deep codebase analysis (4 parallel agents) |
| `/titan:review` | On-demand adversarial code review |
| `/titan:audit` | Security + performance + accessibility |
| `/titan:refactor` | Safe refactoring, tests preserved |
| `/titan:test` | Generate tests, TDD workflows |
| `/titan:quick` | Small task, full quality guarantees |

</td>
<td width="50%" valign="top">

### Session Management

| Command | Purpose |
|---------|---------|
| `/titan:resume` | Pick up where you left off (+ crash recovery) |
| `/titan:pause` | Save state + handoff document |
| `/titan:progress` | Dashboard: phases, costs, blockers, next action |
| `/titan:autopilot` | Auto-run plan/build/verify per phase |
| `/titan:settings` | Configure everything |
| `/titan:help` | Command reference |

### Autonomous Development (v2.0)

| Command | Purpose |
|---------|---------|
| `/titan:00-bootstrap` | Create autonomous scaffold |
| `/titan:loop-start` | Start feature-driven autonomous loop |
| `/titan:loop-status` | Loop health + progress |
| `/titan:loop-stop` | Graceful stop |
| `/titan:verify-e2e` | End-to-end feature verification |

</td>
</tr>
</table>

---

## What v2.1 Added (from GSD-2)

We studied the [GSD-2 framework](https://github.com/gsd-build/gsd-2) — a standalone TypeScript CLI for autonomous AI development — and integrated its best ideas into TITAN's architecture.

| Feature | What It Does | Config |
|---------|-------------|--------|
| **Dynamic model routing** | Classifies tasks as light/standard/heavy, routes to cost-appropriate models. 40-60% cost reduction. | `dynamic_routing.enabled: true` |
| **Verification commands** | Auto-runs lint/test after every task. Auto-fixes failures. | `verification.commands: ["npm test"]` |
| **Git worktree isolation** | Work in isolated worktrees instead of switching branches. | `git.isolation: worktree` |
| **Cost tracking** | Per-task metrics, budget ceiling, forecasting. | `budget.tracking_enabled: true` |
| **Crash recovery** | Lock files + completed-unit tracking + forensic recovery briefings. | `crash_recovery.lock_file: true` |
| **Roadmap reassessment** | After each phase, review the roadmap against new learnings. | `verification.reassess_roadmap: true` |
| **Stuck detection** | Classifies blockers, suggests resolutions, offers auto-resolve. | Built into `/titan:06-build` |
| **UAT scripts** | Generates manual test scripts mapped to acceptance criteria. | Built into `/titan:06-build` |
| **Background captures** | Log stray ideas without interrupting workflow. Triaged at planning. | `captures.enabled: true` |
| **Step mode** | Pause between tasks/waves for review. Graduated oversight. | `step_mode.enabled: true` |

Everything from v2.0 (autonomous loop, TDD strict mode, two-stage verification) is unchanged.

---

## Installation

```bash
# Install globally (Claude Code + OpenCode)
bash install.sh --global

# Claude Code only
bash install.sh --global --claude-only

# Specific project
bash install.sh --project-dir /path/to/project
```

<details>
<summary><strong>What gets installed</strong></summary>

<br/>

- 24 command files to `.claude/commands/titan/`
- 9 agent definitions to `.claude/agents/`
- Templates, domain plugins, and references to `.claude/templates/titan/`

</details>

<details>
<summary><strong>Uninstall</strong></summary>

<br/>

```bash
bash uninstall.sh --global              # Remove commands and agents
bash uninstall.sh --global --purge      # Also remove .titan/ project data
```

</details>

---

## Quick Start

```
/titan:01-init          # Start here
/titan:02-vision        # Define your product
/titan:05-plan          # Plan the first phase
/titan:06-build         # Build it
/titan:07-verify        # Prove it works
/titan:08-ship          # Ship it
```

That's it. Six commands from zero to shipped.

---

## Origin

TITAN synthesizes ideas from multiple AI development frameworks:

- **FORGE** — The original synthesis of PAUL, GSD, and BMAD frameworks
- **GSD-2** — Autonomous execution, crash recovery, cost tracking, dynamic model routing
- **PAUL** — Mandatory reconciliation, acceptance-driven BDD, context brackets
- **BMAD** — Persona-driven planning, progressive artifacts, adversarial review

TITAN takes the best from each and adds what none of them had: novel problem solving workflows, 9 specialized agents, pluggable domain expertise, and a quality verification system that refuses to be skipped.

---

<p align="center">
  <sub>MIT License + <a href="LICENSE">Commons Clause</a></sub>
</p>

<p align="center">
  <em>Built with conviction that one person can change the world — they just need the right tools.</em>
</p>

# TITAN vs GSD-2: Integration Report

> Branch: `gsd2-cannibalize` | Date: 2026-03-17 | Status: NOT MERGED

---

## Executive Summary

GSD-2 (gsd-build/gsd-2) is a **standalone TypeScript application** built on the Pi SDK with native Rust performance modules, a terminal UI, VS Code extension, and programmatic agent session control. TITAN is a **prompt-injection framework** that operates within Claude Code via slash commands.

They solve the same problem — structured AI-assisted software development for solo developers — but with fundamentally different architectures. Neither is strictly "better." Each has clear advantages. This integration cannibalizes GSD-2's best ideas into TITAN without abandoning TITAN's strengths.

**Result:** 11 features integrated. 17 files changed. 1,433 lines added. Zero TITAN features removed.

---

## Part 1: TITAN Before vs After

### By the Numbers

| Metric | Before (main) | After (gsd2-cannibalize) | Delta |
|--------|---------------|--------------------------|-------|
| Total framework lines | 22,472 | 23,902 | +1,430 (+6.4%) |
| Config sections | 11 | 16 | +5 |
| Config lines | 201 | 341 | +140 (+70%) |
| Core spec files | 8 | 11 | +3 |
| Template files | 16 | 18 | +2 |
| Reference docs | 5 | 6 | +1 |
| Build command lines | 487 | 653 | +166 (+34%) |
| Verify command lines | 750 | 801 | +51 (+7%) |
| Settings command lines | 332 | 448 | +116 (+35%) |
| Resume command lines | 194 | 229 | +35 (+18%) |

### New Capabilities Added

| # | Capability | Before | After |
|---|-----------|--------|-------|
| 1 | **Dynamic model routing** | Static profiles only (quality/balanced/budget). Same model for every task in a role. | Heuristic classification (light/standard/heavy) routes tasks to cost-appropriate models. Light tasks get cheaper models. Heavy tasks are protected. 40-60% potential cost savings. |
| 2 | **Verification commands** | Manual — user runs lint/test themselves, or waits for /titan:08-verify to catch issues. | Configurable shell commands auto-run after each task commit. Failures trigger auto-fix with retry limits. Catches regressions immediately. |
| 3 | **Git isolation strategies** | Branch-per-phase only. Requires branch switching. Planning artifacts invisible across branches. | Three options: `branch` (default, unchanged), `worktree` (complete file isolation, no switching, artifacts visible), `none` (direct commits for simple projects). |
| 4 | **Cost/budget tracking** | None. No visibility into token spend or cost per task. | Per-task metrics logged to `.titan/metrics.json`. Budget ceiling with enforcement (warn/pause/halt). Forecasting after N tasks. Cost dashboard in /titan:progress. |
| 5 | **Crash recovery** | HANDOFF.md only (requires explicit /titan:pause before crash). If session crashes without pause, context is lost. | Lock files detect crashes. Completed-units tracking prevents re-execution. Session forensics reconstruct what happened. Recovery briefing shows exactly where to resume. |
| 6 | **Roadmap reassessment** | Roadmap is static after /titan:02-vision. What you planned is what you build, even if you learn it's wrong. | After each phase verifies, /titan:08-verify reviews the roadmap against learnings and suggests adjustments. Prevents building on outdated assumptions. |
| 7 | **UAT script generation** | None. Manual testing is unstructured. | After build completes, generates a UAT script with test cases mapped to acceptance criteria. Gives users a structured way to verify before formal review. |
| 8 | **Stuck detection** | Task blocks → one retry → mark BLOCKED. No analysis of why. | Classifies blocker type (missing dependency, auth issue, test setup, etc.). Suggests specific resolution. Offers auto-resolve for high-confidence cases. |
| 9 | **Background captures** | None. Stray thoughts during execution are lost. | `.titan/CAPTURES.md` stores ideas, concerns, and observations without interrupting workflow. Triaged during planning and verification. |
| 10 | **Step mode** | All-or-nothing: either full autopilot or manual command-by-command. | Configurable pause points: between tasks, between waves, between phases. Graduated oversight without full manual control. |
| 11 | **Completed units tracking** | None. After crash, all tasks in the phase might re-execute. | `.titan/completed-units.json` tracks committed work. Skips already-done tasks on recovery. Cleared when phase completes. |

### Files Modified

| File | Changes | What Changed |
|------|---------|-------------|
| `templates/config.yaml` | +140 lines | 5 new config sections: dynamic routing, git isolation options, verification commands, budget tracking, crash recovery, step mode, captures |
| `commands/core/07-build.md` | +166 lines | Steps 1c (crash recovery check), 1d (dynamic routing setup), Step 2 (worktree option), Steps C-2 through C-5 (verification commands, completed units, cost metrics, stuck detection), Step 6b (UAT generation), Step 6c (lock cleanup) |
| `commands/session/settings.md` | +116 lines | Options 7-11: dynamic routing, budget/cost, crash recovery, verification commands, step mode |
| `commands/session/progress.md` | +57 lines | Steps 8b (cost dashboard), 8c (background captures display) |
| `commands/core/08-verify.md` | +51 lines | Steps 11b (roadmap reassessment), 11c (capture triage) |
| `commands/session/resume.md` | +35 lines | Step 2b (crash detection and recovery briefing) |
| `commands/core/06-plan.md` | +15 lines | Step 3b (review background captures before planning) |
| `commands/core/09-ship.md` | +11 lines | Cost summary section in release report |
| `commands/session/pause.md` | +8 lines | Step 4b (remove build lock on pause) |
| `ARCHITECTURE-SPEC.md` | +62 lines | Full GSD-2 integration section with comparison tables |
| `templates/STATE.md` | +30 lines | Cost & Budget section, Crash Recovery section |

### New Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `references/gsd2-integration.md` | 270 | Complete integration reference — what was taken, why, how it maps |
| `core/cost-tracking.md` | 145 | Cost/budget tracking specification |
| `core/crash-recovery.md` | 138 | Crash recovery & forensics specification |
| `core/dynamic-routing.md` | 89 | Dynamic model routing specification |
| `templates/UAT.md` | 63 | User acceptance test script template |
| `templates/CAPTURES.md` | 34 | Background captures template |

### What Was NOT Changed

These TITAN features remain exactly as they were:

- **Golden Path** (8-step workflow) — unchanged
- **9 specialized agents** — all definitions untouched
- **Domain plugin system** (8 YAML plugins) — unchanged
- **Novel problem solving** (investigate + experiment) — unchanged
- **Adversarial 2-stage verification** — enhanced, not replaced
- **Design mockup generation** (titan-designer) — unchanged
- **Autonomous loop** (v2.0 bootstrap, loop-start/stop/status) — unchanged
- **Progressive persona interviews** (02-vision) — unchanged
- **Knowledge system** (KNOWLEDGE.md) — unchanged
- **Decision reversibility tracking** (DECISIONS.md) — unchanged
- **Context brackets** — unchanged
- **TDD strict mode** — unchanged
- **All power tools** (debug, investigate, experiment, learn, review, test, audit, refactor, scan, quick) — unchanged

---

## Part 2: TITAN vs GSD-2 Overall Comparison

### Architecture

| Dimension | TITAN v2.1 (after integration) | GSD-2 |
|-----------|-------------------------------|-------|
| **Type** | Prompt-injection framework (Claude Code slash commands) | Standalone TypeScript CLI application (Pi SDK) |
| **Runtime** | Runs inside Claude Code — depends on the host's session model | Independent process — can run headless, in CI, overnight |
| **Agent Control** | Prompts injected into Claude Code, hoping the LLM follows instructions | Programmatic TypeScript API — direct session control |
| **UI** | Uses Claude Code's terminal UI | Custom TUI with dashboards, progress trees, keyboard shortcuts |
| **IDE Integration** | None (lives in terminal) | VS Code extension with sidebar, chat participant, 14 commands |
| **Native Performance** | None (pure prompt) | Rust crates for grep, AST parsing, file discovery |
| **Installation** | Shell script copies files to ~/.claude/ | npm install or global CLI |

### Workflow Features

| Feature | TITAN v2.1 | GSD-2 | Verdict |
|---------|-----------|-------|---------|
| **Core workflow** | 8-step Golden Path (init → vision → explore → design → plan → build → verify → ship) | Auto mode state machine (research → plan → execute → complete → reassess) | **TITAN** — more granular, explicit steps; GSD-2 — more autonomous |
| **Agent types** | 9 specialized (executor, verifier, researcher, designer, investigator, strategist, security, optimizer, tester) | 3 bundled (Scout, Researcher, Worker) + extension-provided | **TITAN** — deeper role separation |
| **Domain awareness** | 8 YAML plugins (web, mobile, desktop, audio, game, data, api, infrastructure) with quality gates, patterns, anti-patterns | 16 skills with auto-discovery (frontend, Rust, Tauri, SwiftUI, security, etc.) | **Draw** — different approaches, similar coverage |
| **Novel problem solving** | /titan:investigate + /titan:experiment — systematic hypothesis-driven workflows | No equivalent | **TITAN** |
| **Model routing** | Static profiles + dynamic heuristic routing (light/standard/heavy) | Dynamic complexity-based routing with budget pressure | **Draw** — both now have this (TITAN integrated it) |
| **Verification** | Mandatory 2-stage adversarial review (spec compliance + code quality), halt condition, 5 dimensions | Configurable verification commands, auto-fix retries | **TITAN** — deeper review; GSD-2 — more automated |
| **Design mockups** | titan-designer generates browser-testable HTML/CSS | No equivalent | **TITAN** |
| **Autonomous execution** | Autopilot + autonomous loop (v2.0) with feature manifest | Auto mode as default — walk away, return to built project | **GSD-2** — autonomy is the core design, not an add-on |
| **Cost tracking** | Per-task metrics, budget ceiling, forecasting | Per-unit token/cost ledger, budget pressure, routing history, dashboard | **GSD-2** — more mature (longer iteration); TITAN now has the concept |
| **Crash recovery** | Lock files, completed-units, forensic briefings | Lock files, PID liveness, session forensics, auto-restart | **GSD-2** — has auto-restart, headless recovery; TITAN has the core concept |
| **Git strategy** | branch / worktree / none (3 options) | worktree / branch / none (3 options, worktree default) | **Draw** — same options, different defaults |
| **Cross-session continuity** | STATE.md + HANDOFF.md + lock-based crash recovery | STATE.md + lock files + CONTINUE.md + session forensics | **Draw** — both strong |
| **Multi-terminal** | No | Yes — steer from second terminal via file-based IPC | **GSD-2** |
| **Headless / CI** | No | Yes — `gsd headless` with auto-restart, NDJSON monitoring | **GSD-2** |
| **Parallel milestones** | No (parallel tasks within waves only) | Yes — multiple workers across milestones | **GSD-2** |
| **HTML reports** | No | Yes — self-contained HTML with charts and progress trees | **GSD-2** |
| **Team collaboration** | No (solo-focused) | Yes — shared/local file split, unique IDs, team mode | **GSD-2** |
| **Extension system** | No (domain plugins are the extension point) | 14 bundled extensions + custom extension API | **GSD-2** |
| **TUI dashboard** | No (text-based progress bars in commands) | Full-screen overlay with progress tree, dep graph, metrics, timeline | **GSD-2** |

### Scoring Summary

| Category | TITAN v2.1 | GSD-2 |
|----------|-----------|-------|
| **Workflow structure** | Stronger — explicit 8-step path, more agent specialization | More autonomous — state machine requires less manual orchestration |
| **Quality assurance** | Stronger — adversarial 2-stage review, halt condition, domain gates | Adequate — verification commands catch regressions, but no deep review |
| **Novel problem solving** | Stronger — dedicated investigate + experiment workflows | No equivalent |
| **Autonomy** | Moderate — autopilot exists but isn't the default | Stronger — auto mode is the core design |
| **Observability** | Moderate — cost tracking, progress command | Stronger — TUI dashboard, HTML reports, VS Code extension |
| **Resilience** | Moderate — crash recovery now integrated | Stronger — auto-restart, headless mode, PID liveness |
| **Scalability** | Solo only | Solo + team, parallel milestones |
| **Extensibility** | Domain plugins (YAML) | Full extension API (TypeScript) |
| **Cost efficiency** | Dynamic routing now integrated | Dynamic routing + budget pressure more mature |

### The Fundamental Tradeoff

**TITAN** optimizes for **quality and depth**. Its 9 agents, adversarial verification, domain plugins, and novel problem solving workflows produce thoroughly validated software. The cost is more manual orchestration — you run each step yourself.

**GSD-2** optimizes for **autonomy and throughput**. Its auto-mode state machine, headless CI integration, crash recovery with auto-restart, and multi-terminal steering let you walk away and return to built software. The cost is less depth in verification and no specialized workflows for novel problems.

---

## Part 3: What TITAN Still Doesn't Have (and Whether It Matters)

| GSD-2 Feature | Why TITAN Can't Have It | Does It Matter? |
|---------------|------------------------|-----------------|
| **Standalone runtime** | TITAN is a prompt framework, not an application. It has no process to run. | **Somewhat.** Limits headless/CI use. But TITAN's target user is interactive, not automated pipelines. |
| **Native Rust modules** | No compilation step. TITAN is pure markdown files. | **No.** Performance bottlenecks are in the LLM, not file search. |
| **TUI dashboard** | Claude Code owns the terminal. TITAN can't draw over it. | **Minor.** The /titan:progress command serves the same purpose with less visual flair. |
| **VS Code extension** | Would require a separate codebase and distribution channel. | **Minor.** TITAN works in the terminal. VS Code integration is a different product. |
| **Multi-terminal steering** | Requires a daemon or background process for IPC. | **Minor.** TITAN's session model is one conversation at a time. Most solo developers work this way. |
| **Headless/CI mode** | Requires a standalone runtime that can start LLM sessions. | **Moderate.** Limits CI/CD automation. The autonomous loop partially compensates. |
| **Parallel milestone orchestration** | Requires process management outside Claude Code. | **Low.** Within-wave parallelism covers most needs. |
| **HTML reports** | Could be added as a power tool. Not architecturally blocked. | **Low.** Nice-to-have, not core. |
| **Team collaboration** | Could be added to state management. Not architecturally blocked. | **Moderate.** Growing teams eventually need this. |
| **Extension API** | Would require a plugin system for markdown commands. | **Low.** Domain plugins serve 80% of the need. |

---

## Part 4: Recommendation

**TITAN v2.1 (with GSD-2 integration) is the stronger framework for quality-focused solo development.** It has:

- Deeper verification (adversarial 2-stage review vs simple command execution)
- More specialized agents (9 vs 3)
- Novel problem solving workflows (no GSD-2 equivalent)
- Domain-specific quality gates (8 plugins)
- Design mockup generation
- All of GSD-2's practical innovations (cost tracking, crash recovery, dynamic routing, verification commands)

**GSD-2 is stronger for autonomous, hands-off execution** — but that's a different use case than TITAN's "one person + framework = world-class software" philosophy, which values human oversight at key decision points.

The integration captured GSD-2's most valuable ideas without sacrificing any of TITAN's strengths. The branch is ready for review.

---

_Report generated: 2026-03-17_
_Branch: gsd2-cannibalize (4a730f6)_
_Base: main (ed379b5)_
_Not merged. Not pushed._

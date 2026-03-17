# GSD-2 Integration Reference

> This document details what was cannibalized from GSD-2 (gsd-build/gsd-2),
> why each feature was chosen, and how it maps to TITAN's architecture.

## Source Analysis

**GSD-2** (Get Shit Done v2) is a standalone TypeScript CLI application built on the
Pi SDK with native Rust performance modules. It represents a fundamentally different
architectural approach from TITAN:

- **GSD-2**: Application with programmatic agent session control
- **TITAN**: Prompt-injection framework for Claude Code slash commands

This means we can't port code — we port concepts, adapting them to work within
Claude Code's session model.

## Integration Inventory

### 1. Dynamic Model Routing

**GSD-2 Implementation:**
Sub-millisecond heuristic classification of tasks into Light/Standard/Heavy tiers.
Light tasks route to cheaper models. Heavy tasks are protected from downgrades.
Budget pressure progressively downgrades non-critical tasks.
GSD-2 reports 40-60% token cost savings.

**TITAN Adaptation:**
- `config.yaml` gains `dynamic_routing` section with enable flag, override map, and pressure thresholds
- Build command classifies tasks before dispatching
- Classification logged to `.titan/metrics.json` for analysis
- Heavy tasks (keywords, high step count, in-session mode) never downgraded

**Files Modified:**
- `templates/config.yaml` — new `dynamic_routing` section
- `commands/core/06-build.md` — Step 1d (classification + routing)
- `core/dynamic-routing.md` — detailed spec

---

### 2. Verification Commands

**GSD-2 Implementation:**
Configurable shell commands (npm test, lint, etc.) run automatically after each task.
Failures trigger agent-driven auto-fix with retry limits. This catches regressions
immediately, not during manual verification.

**TITAN Adaptation:**
- `config.yaml` gains `verification.commands` array, `auto_fix` flag, `max_fix_retries`
- Build command runs commands after each successful task commit
- Auto-fix re-dispatches executor with failure context
- Failures recorded as concerns for formal verification

**Files Modified:**
- `templates/config.yaml` — new fields in `verification` section
- `commands/core/06-build.md` — Step C-2 (verification command execution)

---

### 3. Git Worktree Isolation

**GSD-2 Implementation:**
"Branchless worktree architecture" — each milestone works in `.gsd/worktrees/<MID>/`
on a dedicated branch. No branch switching. Planning artifacts stay visible. One
squash-merge per milestone. Eliminated ~770 lines of merge/conflict code.

**TITAN Adaptation:**
- `config.yaml` gains `git.isolation` option: `branch` (default), `worktree`, `none`
- Build command creates worktree when `isolation: worktree`
- Ship command handles worktree cleanup and squash-merge
- `none` mode for hot-reload workflows

**Files Modified:**
- `templates/config.yaml` — new `git.isolation`, `git.worktree_dir`, `git.commit_docs`
- `commands/core/06-build.md` — Step 2 (branch/worktree/none selection)

---

### 4. Cost & Budget Tracking

**GSD-2 Implementation:**
Every unit captures token consumption, USD cost, duration. Data persists in
`metrics.json`. Budget ceiling with enforcement (warn/pause/halt). Forecasting
after N tasks. Dashboard shows spending by phase/model.

**TITAN Adaptation:**
- `config.yaml` gains `budget` section (tracking_enabled, ceiling, enforcement, forecast_after_tasks)
- `.titan/metrics.json` auto-created, updated after each task
- Build command logs metrics and runs forecasting
- Progress command displays cost dashboard
- Budget pressure feeds into dynamic routing decisions

**Files Modified:**
- `templates/config.yaml` — new `budget` section
- `templates/STATE.md` — new "Cost & Budget" section
- `commands/core/06-build.md` — Step C-4 (metric logging + forecasting)
- `commands/session/progress.md` — Step 8b (cost dashboard)
- `core/cost-tracking.md` — detailed spec

---

### 5. Crash Recovery & Session Forensics

**GSD-2 Implementation:**
Lock files track current unit. Session forensics synthesize recovery briefings
from surviving tool calls. PID liveness detection. Auto-restart on crash.

**TITAN Adaptation:**
- `config.yaml` gains `crash_recovery` section (lock_file, lock_path, completed_units_file, forensics)
- Build command writes/updates lock, appends completed units, removes lock on completion
- Resume command checks for stale locks and triggers recovery protocol
- Pause command explicitly removes lock files
- Recovery briefing shows confirmed-committed vs in-progress vs not-started tasks

**Files Modified:**
- `templates/config.yaml` — new `crash_recovery` section
- `templates/STATE.md` — new "Crash Recovery" section
- `commands/core/06-build.md` — Steps 1c, C-3, 6c
- `commands/session/resume.md` — Step 2b (crash detection)
- `commands/session/pause.md` — Step 4b (lock removal)
- `core/crash-recovery.md` — detailed spec

---

### 6. Roadmap Reassessment

**GSD-2 Implementation:**
After each slice completes and verifies, GSD-2 reassesses the roadmap. Learning
from execution may invalidate later slices. The reassessment step explicitly
reviews remaining work against new knowledge.

**TITAN Adaptation:**
- `config.yaml` gains `verification.reassess_roadmap` flag
- Verify command adds Step 11b between knowledge capture and phase completion
- Reassessment reads ROADMAP.md, recent KNOWLEDGE.md entries, and deviations
- Presents adjustments to user for approval before modifying ROADMAP.md

**Files Modified:**
- `templates/config.yaml` — new `verification.reassess_roadmap` flag
- `commands/core/07-verify.md` — Step 11b (roadmap reassessment)

---

### 7. UAT Script Generation

**GSD-2 Implementation:**
GSD-2 generates User Acceptance Test scripts per slice with concrete test cases
mapped to acceptance criteria. These give users a structured way to manually
verify deliverables.

**TITAN Adaptation:**
- `templates/UAT.md` — template for UAT scripts
- Build command generates phase-specific UAT script after all waves complete
- Each test case maps to acceptance criteria with concrete steps

**Files Modified:**
- `templates/UAT.md` — new template
- `commands/core/06-build.md` — Step 6b (UAT generation)

---

### 8. Stuck Detection

**GSD-2 Implementation:**
When a task blocks and retry also blocks, GSD-2 runs diagnostics to classify
the blocker type and suggest resolution. This avoids endless retry loops.

**TITAN Adaptation:**
- Build command adds Step C-5 after blocked tasks
- Classifies blocker type: missing dependency, missing file, auth/permission, test framework
- Suggests specific resolution with confidence level
- Offers auto-resolve for high-confidence cases

**Files Modified:**
- `commands/core/06-build.md` — Step C-5 (stuck detection)

---

### 9. Background Captures

**GSD-2 Implementation:**
`CAPTURES.md` stores stray ideas, concerns, and observations during execution
without interrupting the current workflow. Triaged during planning and verification.

**TITAN Adaptation:**
- `templates/CAPTURES.md` — new template
- `config.yaml` gains `captures.enabled` flag
- Verify command triages captures in Step 11c
- Progress command displays unreviewed captures count

**Files Modified:**
- `templates/CAPTURES.md` — new template
- `templates/config.yaml` — new `captures` section
- `commands/core/07-verify.md` — Step 11c (capture triage)
- `commands/session/progress.md` — Step 8c (captures display)

---

### 10. Step Mode

**GSD-2 Implementation:**
Pause between units for human review. More granular than checkpoints —
every task gets a review opportunity. Useful for supervised execution
without full manual control.

**TITAN Adaptation:**
- `config.yaml` gains `step_mode` section (enabled, pause_between_waves, pause_between_phases)
- Build command checks step_mode before each task/wave
- Autopilot respects pause_between_phases

**Files Modified:**
- `templates/config.yaml` — new `step_mode` section
- `commands/session/settings.md` — Option 11 (step mode settings)

---

### 11. Completed Units Tracking

**GSD-2 Implementation:**
`completed-units.json` tracks every successfully committed unit. On crash recovery,
already-completed units are skipped, preventing duplicate execution.

**TITAN Adaptation:**
- Part of crash recovery system
- `.titan/completed-units.json` tracks phase, task, commit hash, timestamp
- Build command checks before dispatching any task
- Cleared when phase completes

**Files Modified:**
- (Covered by crash recovery integration)

---

## Features Evaluated But Not Integrated

### Multi-Terminal Steering
GSD-2 allows steering from a second terminal via file-based IPC. This requires
a running daemon or background process, which TITAN (as a prompt framework within
Claude Code) cannot provide. The concept is sound but the architecture doesn't fit.

### HTML Report Generation
GSD-2 generates self-contained HTML reports with charts and progress trees after
milestone completion. While visually impressive, this is a presentation layer feature
that doesn't improve the core workflow. Could be added later as a power tool command.

### Parallel Milestone Orchestration
Running multiple milestones simultaneously requires process management outside
Claude Code's scope. Individual tasks can already run in parallel within a wave.

### Headless/CI Mode
Requires a standalone runtime that can operate without Claude Code's interactive
session. Fundamentally different execution model.

### Skills Auto-Discovery
GSD-2 has 16 bundled skills with auto-discovery. TITAN's domain plugins serve
a similar purpose with a different mechanism (YAML-based quality gates vs
prompt-based skill injection).

### Layered Memory (L1-L4)
GSD-2 formalizes four memory layers: Working Context, Session/Episodic, Project
Semantic, and Ground Truth. While the concept is valuable, TITAN already implements
similar patterns through its state files (STATE.md = L1, KNOWLEDGE.md = L2,
ARCHITECTURE.md/REQUIREMENTS.md = L3, filesystem/git = L4). The formal taxonomy
informed our context management philosophy but didn't require structural changes.

---

## Version History

- **v2.1** (2026-03-17): Initial GSD-2 integration — 11 features cannibalized

# TITAN v2.0 — Autonomous Loop Upgrade Specification

**Version:** 2.0 — "HYDRA" (Harness-Yielded Durable Runtime Architecture)
**Builds on:** TITAN v1.1 Upgrade Recommendations (11 upgrades, 4 phases)
**Author:** Clint Moody
**Date:** March 2026
**Status:** SPECIFICATION — Ready for implementation

---

## Executive Summary

TITAN v1.1 made the framework smarter within a single session — tier routing, oracle loops, loop governors, context budgets. But it still requires a human in the driver's seat for every session. v2.0 transforms TITAN into a **nearly fully autonomous long-running agent system** that can loop across many sessions, self-orient on startup, verify its own work end-to-end, and only surface to the user when genuinely stuck.

The core insight comes from converging research by Anthropic, OpenAI, Vercel, and the OpenClaw project: **the model is already capable enough — what's missing is the harness.** Specifically, three architectural pillars unlock long-running autonomy:

1. **Legible Environment** — Each new session can instantly understand where things are
2. **Verification-Driven Progress** — The system proves its work before moving on
3. **Generic Tooling + Trust** — Give the model native tools and let it explore

This spec adds **9 new upgrades (12–20)** organized into **2 new phases (5–6)** that layer on top of the existing v1.1 implementation plan.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    TITAN v2.0 AUTONOMOUS LOOP                   │
│                                                                 │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────┐   │
│  │  DAEMON   │───▶│ INITIALIZER  │───▶│  SESSION CONTROLLER  │   │
│  │ (cron /   │    │    AGENT     │    │  (loop orchestrator) │   │
│  │  trigger) │    │ (first-run   │    │                      │   │
│  └──────────┘    │  only)       │    │  ┌────────────────┐  │   │
│       │          └──────────────┘    │  │  CODING AGENT  │  │   │
│       │                              │  │  (incremental  │  │   │
│       ▼                              │  │   progress)    │  │   │
│  ┌──────────┐                        │  └───────┬────────┘  │   │
│  │ TRIGGER  │                        │          │           │   │
│  │ ENGINE   │                        │  ┌───────▼────────┐  │   │
│  │ (watch / │                        │  │   VERIFIER     │  │   │
│  │  cron /  │                        │  │   AGENT        │  │   │
│  │  webhook)│                        │  │  (end-to-end)  │  │   │
│  └──────────┘                        │  └───────┬────────┘  │   │
│                                      │          │           │   │
│                                      │  ┌───────▼────────┐  │   │
│                                      │  │  CHECKPOINT    │  │   │
│                                      │  │  (git + state) │  │   │
│                                      │  └────────────────┘  │   │
│                                      └──────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 LEGIBLE ENVIRONMENT                       │   │
│  │  .titan/MANIFEST.json    (feature list + pass/fail)      │   │
│  │  .titan/PROGRESS.md      (session log, structured)       │   │
│  │  .titan/LOOP-STATE.json  (current loop position)         │   │
│  │  .titan/docs/            (table-of-contents architecture)│   │
│  │  git history             (revertable, descriptive)       │   │
│  │  init.sh                 (reproducible environment)      │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 5 — Legible Environment (Harness Foundation)

These upgrades establish the structured environment that makes autonomous looping possible. Without legibility, every new session wastes tokens re-discovering project state.

### Upgrade 12: Initializer Agent Pattern

**Source:** Anthropic's effective harnesses, OpenAI's harness engineering

**Problem:** Currently, TITAN's `/titan:01-init` sets up project structure but doesn't create an environment optimized for autonomous multi-session work. Each new session must manually re-orient.

**Solution:** Split the first-run into a specialized **Initializer Agent** that creates the full autonomous scaffold. Every subsequent session uses a different prompt (the **Coding Agent** prompt) that assumes the scaffold exists.

**Implementation:**

New file: `.titan/core/initializer-agent.md`

The Initializer Agent executes on first run and produces:

1. **`init.sh`** — Idempotent script that stands up the dev environment (installs deps, starts servers, runs migrations, seeds data). Every future session runs this first. Must be re-runnable without side effects.

2. **`.titan/MANIFEST.json`** — The comprehensive feature list derived from the project vision. Every feature is a structured JSON object:
   ```json
   {
     "id": "F-001",
     "category": "core",
     "description": "User can create a new project with audio file import",
     "acceptance_criteria": [
       "File picker opens on 'New Project'",
       "WAV/AIFF/FLAC files accepted",
       "Progress indicator during import",
       "Project appears in sidebar after import"
     ],
     "priority": 1,
     "status": "failing",
     "dependencies": [],
     "estimated_sessions": 1
   }
   ```
   - **All features start as `"failing"`** — this prevents premature victory declaration
   - **JSON format is mandatory** — models are less likely to inappropriately edit or overwrite JSON compared to Markdown (validated by Anthropic's research)
   - **Strongly-worded guard:** "It is unacceptable to remove or edit feature definitions. Only the `status` field may be changed, and only after end-to-end verification."

3. **`.titan/PROGRESS.md`** — Structured session log with append-only entries:
   ```markdown
   ## Session 14 — 2026-03-05T14:30:00Z
   **Model:** claude-opus-4-6
   **Feature:** F-023 (Spectrum analyzer peak hold)
   **Status:** COMPLETED
   **Changes:** Implemented peak decay algorithm, added hold-time parameter
   **Commits:** a1b2c3d, e4f5g6h
   **Verification:** E2E test passed — peaks hold for configured duration, decay smooth
   **Next Priority:** F-024 (Frequency band labels)
   **Environment State:** Clean — all tests passing, dev server stable
   ```

4. **`.titan/docs/`** — Structured documentation directory (OpenAI pattern). Instead of one giant doc, this is a table-of-contents architecture:
   ```
   .titan/docs/
   ├── INDEX.md              ← Table of contents (what AGENTS.md points to)
   ├── architecture.md       ← System architecture overview
   ├── design/               ← Design decisions and specs
   │   ├── module-specs/     ← Per-module specifications
   │   └── decisions.md      ← ADR log
   ├── execution-plan.md     ← Current sprint/phase plan
   ├── quality.md            ← Quality grades per domain
   └── domain/               ← Domain-specific reference
       └── audio-dsp.md      ← (example: OBSERVATORY DSP reference)
   ```

5. **Initial git commit** — Clean baseline with descriptive message. All future sessions can `git log` and `git diff` to understand trajectory.

**New command:** `/titan:03-bootstrap`
- Replaces the initialization portion of `/titan:01-init`
- Only runs once per project (detects `.titan/MANIFEST.json` existence)
- Generates all 5 artifacts above
- Estimates total feature count and session count

**Modified command:** `/titan:01-init` now checks for bootstrap artifacts and skips to coding-agent mode if they exist.

---

### Upgrade 13: Session Orientation Protocol

**Source:** Anthropic's "getting up to speed" pattern, OpenAI's repository-as-knowledge-base

**Problem:** Every new session currently requires the user to re-explain context or the agent to guess. The v1.1 Session Handoff Protocol (Upgrade 11) helps but requires manual triggering.

**Solution:** Every coding-agent session begins with an **automatic orientation sequence** before any work begins. This is not optional — it's hardwired into the session start.

**Implementation:**

New file: `.titan/core/session-orientation.md`

The orientation sequence runs at the start of every autonomous session:

```
STEP 1: Orient
  → Read .titan/PROGRESS.md (last 3 sessions)
  → Read .titan/LOOP-STATE.json (current position in loop)
  → git log --oneline -10

STEP 2: Verify Environment
  → Run init.sh (start dev server, install any new deps)
  → Run smoke test against running app/build
  → If smoke test fails → FIX EXISTING BUGS before any new work
  → Record environment health in LOOP-STATE

STEP 3: Select Next Task
  → Read .titan/MANIFEST.json
  → Identify highest-priority "failing" feature
  → Check dependencies (don't start F-024 if F-023 is still failing)
  → Declare selected feature in PROGRESS.md

STEP 4: Work (single feature, incremental)
  → Implement the feature
  → Write/update tests
  → Verify end-to-end (see Upgrade 15)
  → Only mark status as "passing" after E2E verification

STEP 5: Checkpoint
  → git commit with descriptive message
  → Append session entry to PROGRESS.md
  → Update LOOP-STATE.json with next priority
  → Ensure environment is in clean state (no half-implemented features)
```

**Critical rules:**
- **One feature per session** — This prevents the one-shotting failure mode where the agent tries to build everything at once and runs out of context
- **Fix before build** — If the smoke test reveals existing bugs, the session's entire purpose becomes fixing them. Do not layer new features on a broken foundation
- **Clean state mandatory** — The code at session end must be merge-ready. No TODO stubs, no commented-out blocks, no failing tests from the current feature

**New file:** `.titan/LOOP-STATE.json`
```json
{
  "loop_id": "loop-2026-03-05-001",
  "status": "running",
  "current_session": 14,
  "current_feature": "F-023",
  "last_checkpoint": "2026-03-05T14:30:00Z",
  "manifest_progress": {
    "total": 47,
    "passing": 22,
    "failing": 25
  },
  "environment_health": "green",
  "consecutive_failures": 0,
  "escalation_needed": false,
  "escalation_reason": null,
  "next_priority": "F-024",
  "estimated_sessions_remaining": 18
}
```

---

### Upgrade 14: Progressive Documentation System

**Source:** OpenAI's docs-as-knowledge-base, OpenClaw's workspace skills

**Problem:** Currently, `.titan/KNOWLEDGE.md` and `DECISIONS.md` are flat files that grow unbounded. As projects scale, agents can't efficiently retrieve the specific context they need.

**Solution:** Adopt the **table-of-contents pattern** from OpenAI's harness engineering. The primary agent instructions file (`.titan/AGENTS.md` or equivalent) stays small (~100 lines) and serves as a map pointing to deeper sources of truth in `.titan/docs/`.

**Implementation:**

New file: `.titan/core/progressive-docs.md`

**`.titan/AGENTS.md`** (injected into every session context):
```markdown
# TITAN Project: [Project Name]

## Quick Orientation
- Architecture: see docs/architecture.md
- Current plan: see docs/execution-plan.md
- Design decisions: see docs/decisions.md
- Module specs: see docs/design/module-specs/
- Quality status: see docs/quality.md
- Domain reference: see docs/domain/

## Active Constraints
[Short list of 5-10 critical rules — module boundaries, naming conventions, etc.]

## Working Agreements
- All state lives in .titan/ — context clears lose nothing
- Features tracked in MANIFEST.json (JSON, not markdown)
- One feature per session, clean state at end
- Environment must pass smoke test before new work
- All features verified end-to-end before marking "passing"
```

**Staleness prevention:**
- A background maintenance task (triggered by `/titan:audit` or automatically during orientation) scans docs for staleness indicators: files not modified in 10+ sessions, docs that reference deleted code paths, broken cross-references
- Stale docs get flagged in `docs/quality.md` with a `STALE` grade
- The coding agent is prompted to update docs when it modifies related code

**Knowledge partitioning for agent context narrowing (pairs with v1.1 Upgrade 6):**
- Each agent only gets the docs relevant to its role
- Executor gets: architecture.md + relevant module-spec + execution-plan
- Verifier gets: module-spec + quality.md + test expectations
- Security agent gets: architecture.md + security.md + decisions.md

---

## Phase 6 — Autonomous Loop Engine

These upgrades enable TITAN to run continuously across sessions without human intervention, only escalating when genuinely stuck.

### Upgrade 15: End-to-End Verification Harness

**Source:** Anthropic's Puppeteer testing discovery, OpenAI's Chrome DevTools integration

**Problem:** v1.1's Oracle Verification Loop (Upgrade 2) runs build-level checks (compile, lint, unit test). But Anthropic discovered that agents consistently mark features as complete when they pass unit tests but fail end-to-end. The agent can't see what a user would see.

**Solution:** Add a **full E2E verification layer** that tests features the way a human would — by actually running the application and interacting with it.

**Implementation:**

New file: `.titan/core/e2e-verification.md`

**Domain-specific E2E strategies:**

| Domain | E2E Verification Approach |
|--------|--------------------------|
| **Audio Plugin (VST/AU)** | Build plugin → load in test host (pluginval, JUCE AudioPluginHost) → send test audio signal → verify output signal characteristics → check UI renders (screenshot comparison) |
| **Web App** | Start dev server → Puppeteer/Playwright navigation → interact with UI → verify DOM state → screenshot for visual regression |
| **CLI Tool** | Run command with known inputs → verify stdout/stderr → check output files → verify exit codes |
| **API** | Start server → send HTTP requests → verify response bodies/codes → check database state |
| **Desktop App** | Launch app → accessibility tree inspection → simulated input → verify window state |

**Audio-specific verification (for OBSERVATORY and similar):**
```
VERIFY: Audio Plugin Feature
  1. Build: cmake --build . (must succeed with 0 warnings)
  2. Validate: pluginval --validate <plugin_path> (must pass all tests)
  3. Load: Open in AudioPluginHost with test configuration
  4. Signal test: Send known test signal → capture output → compare against expected
  5. Parameter test: Set each parameter → verify behavior changes
  6. UI test: Screenshot comparison against baseline (if UI exists)
  7. Resource test: Monitor CPU/memory during 30-second stress test
```

**Verification before status change:**
- A feature's status in MANIFEST.json can ONLY change from "failing" to "passing" if the E2E verification passes
- The agent must log the verification result in PROGRESS.md
- If E2E fails, the agent must fix the issue and re-verify (pairs with v1.1 Oracle Loop)

**New command:** `/titan:verify-e2e [feature-id]`
- Runs the full E2E verification suite for a specific feature
- Can also run `/titan:verify-e2e --all` to regression-test all "passing" features
- Outputs structured results that get appended to PROGRESS.md

---

### Upgrade 16: Autonomous Loop Controller

**Source:** OpenClaw's always-on daemon + trigger architecture, Anthropic's multi-session coding agent

**Problem:** TITAN currently requires a human to start each session, pick the next task, and decide when to continue. For long-running projects (like building OBSERVATORY from scratch), this means the human becomes the bottleneck.

**Solution:** Introduce a **Loop Controller** that orchestrates continuous sessions. The controller runs the session orientation → work → checkpoint cycle in a loop, only pausing for defined escalation conditions.

**Implementation:**

New file: `.titan/core/loop-controller.md`
New command: `/titan:loop-start`
New command: `/titan:loop-stop`
New command: `/titan:loop-status`

**Loop Controller architecture:**

```
┌─────────────────────────────────────────────┐
│              LOOP CONTROLLER                 │
│                                             │
│  while (MANIFEST has failing features       │
│         AND no escalation needed            │
│         AND loop not manually stopped):     │
│                                             │
│    1. Run Session Orientation (Upgrade 13)  │
│    2. Execute Coding Agent on next feature  │
│    3. Run E2E Verification (Upgrade 15)     │
│    4. Checkpoint (git + PROGRESS + STATE)   │
│    5. Evaluate loop health                  │
│    6. If healthy → continue                 │
│    7. If unhealthy → escalate to user       │
│                                             │
│  Session boundary = context window limit    │
│  or feature completion, whichever first     │
└─────────────────────────────────────────────┘
```

**Loop health evaluation (extends v1.1 Loop Governor, Upgrade 8):**

| Condition | Threshold | Action |
|-----------|-----------|--------|
| `THRASH_DETECTED` | Same error 3× across sessions | Pause + escalate |
| `STALL_DETECTED` | Zero features completed in 3 sessions | Pause + escalate |
| `REGRESSION_DETECTED` | Previously-passing feature now fails | Stop new work, fix regression |
| `CONTEXT_EXHAUSTION` | Context RED zone hit before feature complete | Checkpoint mid-feature, continue in new session |
| `CONSECUTIVE_FAILURES` | 3+ features fail E2E in a row | Pause + escalate — possible architecture issue |
| `ENVIRONMENT_BROKEN` | init.sh or smoke test fails | Stop all work, fix environment |
| `BUDGET_LIMIT` | Token/cost budget exceeded | Pause + notify user |

**Escalation protocol:**
When the loop pauses for escalation, it generates a structured escalation report:

```markdown
## ESCALATION REPORT — Loop loop-2026-03-05-001

**Reason:** THRASH_DETECTED
**Feature:** F-023 (Spectrum analyzer peak hold)
**Sessions affected:** 12, 13, 14
**Error pattern:** Peak values not decaying — same NaN propagation in decay buffer
**What was tried:**
  - Session 12: Added NaN guard on input
  - Session 13: Rewrote decay buffer initialization
  - Session 14: Switched to exponential moving average
**Diagnosis:** Likely upstream issue in FFT output normalization
**Recommended action:** Human review of FFT pipeline (files: src/dsp/fft_processor.cpp lines 142-189)
**To resume:** /titan:loop-start --from F-023
```

**Implementation as Claude Code workflow:**

The loop controller is implemented as a shell script that invokes Claude Code sessions:

```bash
#!/bin/bash
# .titan/scripts/titan-loop.sh
# Autonomous loop controller for TITAN

while true; do
  # Check if loop should continue
  LOOP_STATE=$(cat .titan/LOOP-STATE.json)
  STATUS=$(echo "$LOOP_STATE" | jq -r '.status')

  if [ "$STATUS" != "running" ]; then
    echo "Loop paused: $(echo "$LOOP_STATE" | jq -r '.escalation_reason')"
    exit 0
  fi

  # Run a session via Claude Code
  claude-code --prompt "$(cat .titan/prompts/coding-agent.md)" \
    --system "$(cat .titan/AGENTS.md)" \
    --max-tokens 200000

  # Brief cooldown between sessions
  sleep 5
done
```

**Alternative: Claude Code SDK / Agent SDK integration:**
For more sophisticated control, the loop can be implemented using the Claude Agent SDK directly, with programmatic access to session management, tool registration, and context compaction.

---

### Upgrade 17: Trigger Engine

**Source:** OpenClaw's cron + trigger + webhook architecture

**Problem:** The autonomous loop only handles "grind through the feature list" workflows. Real development also involves reactive work — responding to test failures, handling upstream changes, processing user feedback.

**Solution:** Add a **Trigger Engine** that can start or redirect the loop based on external events.

**Implementation:**

New file: `.titan/core/trigger-engine.md`
New file: `.titan/triggers/`

**Trigger types:**

1. **Cron triggers** — Scheduled autonomous work sessions
   ```json
   {
     "id": "nightly-build",
     "type": "cron",
     "schedule": "0 2 * * *",
     "action": "loop-session",
     "config": {
       "max_sessions": 3,
       "priority_filter": "core"
     }
   }
   ```

2. **File-watch triggers** — React to changes in the project
   ```json
   {
     "id": "spec-change",
     "type": "watch",
     "paths": [".titan/docs/design/**/*.md"],
     "action": "re-plan",
     "config": {
       "debounce_seconds": 30
     }
   }
   ```

3. **Webhook triggers** — External events (CI failure, PR comment, etc.)
   ```json
   {
     "id": "ci-failure",
     "type": "webhook",
     "endpoint": "/titan/webhook/ci",
     "action": "diagnose-and-fix",
     "config": {
       "source": "github-actions",
       "auto_fix": true
     }
   }
   ```

4. **Manual triggers** — User initiates with context
   ```json
   {
     "id": "user-request",
     "type": "manual",
     "action": "custom-task",
     "config": {
       "requires_description": true
     }
   }
   ```

**Trigger → Loop integration:**
- Cron triggers start the loop controller if not already running
- Watch triggers inject priority tasks into MANIFEST.json
- Webhook triggers can pause the current feature and redirect to urgent work
- All triggers log to `.titan/TRIGGER-LOG.md`

---

### Upgrade 18: Generic Tooling Philosophy

**Source:** Vercel's text-to-SQL agent redesign, Anthropic's bash-first findings, OpenClaw's minimal toolset

**Problem:** TITAN v1.0 includes 9 specialized agents with domain-specific prompting. While this provides expertise, Vercel found that replacing specialized tools with a single bash tool made their agent 3.5× faster with higher success rates. Models perform better with tools they've seen billions of training tokens for.

**Solution:** Restructure TITAN's tooling philosophy to **maximize generic tools, minimize bespoke wrappers.** Specialized agents keep their domain knowledge but use generic tools to execute.

**Implementation:**

New file: `.titan/core/tooling-philosophy.md`

**The tooling hierarchy:**

```
TIER 1 (Always available — generic, model-native):
  - bash (run any command)
  - read/write/edit files
  - git operations
  - grep / find / ripgrep

TIER 2 (Domain helpers — thin wrappers around CLI tools):
  - build: cmake/make/cargo/npm (invoked via bash)
  - test: ctest/vitest/pytest (invoked via bash)
  - lint: clang-tidy/eslint/clippy (invoked via bash)
  - format: clang-format/prettier/rustfmt (invoked via bash)

TIER 3 (Environment interaction — when bash isn't enough):
  - Browser automation (Puppeteer/Playwright via MCP)
  - Audio host automation (pluginval, test host via CLI)
  - Screenshot/visual comparison

TIER 4 (Specialized — used sparingly, only when generic fails):
  - Domain-specific analysis tools
  - Custom verification scripts
```

**Key principle:** Every TITAN agent prompt should prefer bash-native approaches. Instead of:
```
"Use the custom DSP analysis tool to verify frequency response"
```
Write:
```
"Run the frequency response test: ./scripts/test-freq-response.sh --input test_sweep.wav --expected flat_response.json"
```

**What this means for existing agents:**
- Agents keep their specialized *knowledge* (DSP theory, security patterns, etc.)
- Agents lose specialized *tools* in favor of bash + standard CLI
- The executor agent's primary tool is `bash` — everything else is a fallback
- This aligns with OpenClaw's architecture: basic read/write/edit/bash + a skill library for expanded capabilities

**Modified files:** All 9 agent definitions updated with "Tooling Preference" section that mandates bash-first approach.

---

### Upgrade 19: Architectural Enforcement Layer

**Source:** OpenAI's linters + structural tests + pre-commit hooks, OpenClaw's git-hooks directory

**Problem:** Over long autonomous runs (dozens of sessions), code quality drifts. Without mechanical enforcement, the agent can introduce architectural violations, dependency cycles, or style inconsistencies that compound over time.

**Solution:** Add a **deterministic enforcement layer** that runs automatically and catches violations before they're committed. This is not prompt engineering — it's mechanical rules that the agent cannot bypass.

**Implementation:**

New file: `.titan/core/enforcement.md`
New directory: `.titan/enforcement/`

**Enforcement components:**

1. **Git pre-commit hooks** (`.titan/enforcement/pre-commit`)
   - Lint check (project-appropriate linter)
   - Format check (project-appropriate formatter)
   - Structural test suite (see below)
   - MANIFEST.json schema validation
   - No TODO/FIXME/HACK in committed code (forces agent to finish work)

2. **Structural tests** (`.titan/enforcement/structural-tests/`)
   - Module boundary validation (no circular deps, no cross-cutting imports)
   - Dependency direction enforcement (e.g., UI → Service → Core → Types, never reverse)
   - File naming convention checks
   - Maximum file size limits (force decomposition)
   - Test coverage thresholds per module

3. **Architecture rules** (`.titan/enforcement/architecture-rules.json`)
   ```json
   {
     "dependency_layers": ["types", "core", "dsp", "service", "ui"],
     "dependency_direction": "down_only",
     "module_boundaries": {
       "dsp": {
         "allowed_imports": ["types", "core"],
         "forbidden_imports": ["ui", "service"]
       },
       "ui": {
         "allowed_imports": ["types", "core", "service"],
         "forbidden_imports": ["dsp"]
       }
     },
     "max_file_lines": 500,
     "required_test_coverage": 0.70
   }
   ```

4. **Linter error messages as teaching context:**
   - Every enforcement failure message includes WHY it's wrong and HOW to fix it
   - This follows OpenAI's insight that linter errors should double as context for the next attempt
   - Example: Instead of "Import violation: dsp/fft.cpp imports ui/renderer.h"
   - Write: "ARCHITECTURAL VIOLATION: dsp/fft.cpp imports ui/renderer.h. The DSP layer must not depend on the UI layer. If FFT results need to reach the renderer, expose them through the service layer (e.g., service/analysis_service.h). See docs/architecture.md#module-boundaries."

**Integration with autonomous loop:**
- Pre-commit hooks run automatically — the agent can't bypass them
- If a commit is rejected, the agent sees the teaching error message and self-corrects
- Structural tests run as part of the E2E verification suite (Upgrade 15)
- Architecture rules are loaded during Session Orientation (Upgrade 13)

---

### Upgrade 20: Local Semantic Knowledge Store (Optional)

**Source:** Open Brain architecture (Supabase + pgvector + OpenRouter embeddings), adapted for local-only operation

**Problem:** Several TITAN subsystems accumulate unstructured knowledge over time — ERROR-PATTERNS.md (v1.1 Upgrade 4), KNOWLEDGE.md, DECISIONS.md, and PROGRESS.md session logs. As flat files, these work fine for weeks. But after months of autonomous looping across multiple projects, grepping through hundreds of error patterns or thousands of session entries becomes a retrieval bottleneck. The agent diagnosing "why is my FFT output producing NaN" would benefit from semantic similarity search across all past encounters, not keyword matching.

**Why not a full vector DB service:** The core autonomous loop (Upgrades 12–19) deliberately avoids external dependencies. Adding a cloud-hosted database (Supabase, Pinecone, etc.) introduces network dependency, API costs, and a new failure mode during overnight runs. The file-based approach (MANIFEST.json, PROGRESS.md, git log) must remain the primary system — it works with `cat` and `grep` and never goes down.

**Solution:** An **optional, local-only** semantic knowledge store using SQLite + vector extensions + a local embedding model. Zero infrastructure, zero API costs, zero network dependency. It's just a file (`.titan/knowledge.db`) that travels with the project. The system works without it — the DB makes long-term retrieval smarter, not possible.

**Implementation:**

New file: `.titan/core/knowledge-store.md`
New file: `.titan/scripts/knowledge-store.sh`
New directory: `.titan/knowledge/`

**Technology stack:**

| Component | Tool | Why |
|-----------|------|-----|
| Database | SQLite + `sqlite-vec` extension | Zero infrastructure — it's a file. No server process. Ships as a single .so/.dylib |
| Embeddings | Ollama + `nomic-embed-text` (768-dim) | Runs locally, no API key, no cost, no network. ~270MB model, fast inference |
| Fallback | Raw text grep on flat files | If Ollama isn't available or DB is missing, everything degrades gracefully to grep |

**What gets indexed (and what doesn't):**

| Indexed in knowledge.db | NOT indexed (stays as structured files) |
|-------------------------|----------------------------------------|
| Error patterns (from ERROR-PATTERNS.md) | MANIFEST.json (structured, small, grep-friendly) |
| Session summaries (from PROGRESS.md) | LOOP-STATE.json (single current-state object) |
| Architecture decisions (from DECISIONS.md) | Architecture rules (deterministic, not semantic) |
| Accumulated domain knowledge (from KNOWLEDGE.md) | Git history (already has `git log --grep`) |
| Cross-project learnings (if multi-project) | docs/ directory (table-of-contents, direct access) |

**Schema:**

```sql
CREATE TABLE knowledge (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  source TEXT NOT NULL,          -- 'error_pattern', 'session', 'decision', 'domain', 'cross_project'
  project TEXT,                  -- project identifier (for cross-project queries)
  created_at TEXT DEFAULT (datetime('now')),
  metadata TEXT,                 -- JSON: topics, severity, related_features, etc.
  embedding BLOB                -- 768-dim float32 vector from nomic-embed-text
);

-- sqlite-vec virtual table for similarity search
CREATE VIRTUAL TABLE knowledge_vec USING vec0(
  id INTEGER PRIMARY KEY,
  embedding float[768]
);
```

**Ingest flow:**
```
PROGRESS.md entry written (end of session)
  → Extract session summary text
  → Generate embedding locally: ollama embed nomic-embed-text "summary text"
  → INSERT into knowledge + knowledge_vec
  → Original flat file remains unchanged (DB is supplementary)

ERROR-PATTERNS.md entry appended
  → Same flow: embed → insert
  → Tag with source='error_pattern' + metadata for error type, severity

DECISIONS.md entry added
  → Same flow: embed → insert
  → Tag with source='decision' + metadata for affected modules
```

**Retrieval flow (during Session Orientation, Upgrade 13):**
```
Agent encounters a bug or needs context
  → Generate embedding of the query: ollama embed nomic-embed-text "NaN in FFT output buffer"
  → SELECT from knowledge_vec ORDER BY distance(embedding, query_vec) LIMIT 5
  → Returns semantically similar past encounters regardless of keyword overlap
  → Agent gets: "Session 47 on Project X had the same NaN issue — root cause was
    uninitialized buffer in ring allocator, fixed by zero-filling on resize"
```

**Graceful degradation:**
- If Ollama isn't installed → skip embedding, fall back to grep on flat files
- If knowledge.db doesn't exist → create on first use, or operate without it
- If sqlite-vec isn't available → use FTS5 (SQLite full-text search) as a keyword fallback
- The loop controller (Upgrade 16) NEVER depends on the knowledge store — it's an enhancement, not a requirement

**Cross-project knowledge (the real payoff):**

The knowledge store can optionally live at `~/.titan/global-knowledge.db` in addition to the per-project `.titan/knowledge.db`. This enables:
- Error patterns from Project A help diagnose issues in Project B
- Architecture decisions from past projects inform new ones
- Domain knowledge (DSP theory, C++ patterns, JUCE idioms) accumulates across your entire development history
- This mirrors Open Brain's role as a shared persistent memory across tools, but local and project-aware

**Cost analysis:**
- SQLite: free, no server
- sqlite-vec: free, open source, single file extension
- Ollama: free, local
- nomic-embed-text model: ~270MB download, then free forever
- Embedding speed: ~50ms per thought on Apple Silicon
- Storage: ~1KB per entry (text + 768 floats) — 10,000 entries ≈ 10MB
- Total ongoing cost: **$0.00/month**

**New commands:**

| Command | Purpose |
|---------|---------|
| `/titan:knowledge-init` | Set up knowledge.db + install sqlite-vec + pull Ollama model |
| `/titan:knowledge-search <query>` | Semantic search across accumulated knowledge |
| `/titan:knowledge-ingest` | Manually re-index flat files into the DB |
| `/titan:knowledge-status` | Show DB stats: entry count, sources, staleness |

**Integration points:**
- Session Orientation (Upgrade 13): After reading PROGRESS.md, optionally query knowledge store for relevant past context
- Error diagnosis (v1.1 Upgrade 4): Before diagnosing, search knowledge store for similar past errors
- Verifier agent: Search for known false-positive patterns before flagging issues
- Cross-session learning: Each session checkpoint automatically ingests its summary

---

## New Commands Summary

| Command | Phase | Purpose |
|---------|-------|---------|
| `/titan:03-bootstrap` | 5 | First-run initializer — creates autonomous scaffold |
| `/titan:verify-e2e` | 6 | End-to-end verification for features |
| `/titan:loop-start` | 6 | Start autonomous loop controller |
| `/titan:loop-stop` | 6 | Gracefully stop the loop (finish current feature) |
| `/titan:loop-status` | 6 | Show loop health, progress, and next priority |
| `/titan:trigger-add` | 6 | Add a new trigger (cron/watch/webhook) |
| `/titan:trigger-list` | 6 | List active triggers |
| `/titan:enforce` | 6 | Run enforcement suite manually |
| `/titan:knowledge-init` | 6 (optional) | Set up local semantic knowledge store |
| `/titan:knowledge-search` | 6 (optional) | Semantic search across accumulated knowledge |
| `/titan:knowledge-ingest` | 6 (optional) | Re-index flat files into knowledge DB |
| `/titan:knowledge-status` | 6 (optional) | Show knowledge store stats |

---

## New Files Summary

### Phase 5 — Legible Environment
```
.titan/core/initializer-agent.md       — Initializer agent prompt + behavior
.titan/core/session-orientation.md     — Automatic orientation sequence
.titan/core/progressive-docs.md        — Documentation architecture guide
.titan/MANIFEST.json                   — Feature list (generated per-project)
.titan/PROGRESS.md                     — Session log (append-only)
.titan/LOOP-STATE.json                 — Current loop position
.titan/AGENTS.md                       — Table-of-contents agent instructions
.titan/docs/INDEX.md                   — Documentation index
.titan/docs/architecture.md            — System architecture
.titan/docs/execution-plan.md          — Current plan
.titan/docs/quality.md                 — Quality grades per domain
.titan/docs/design/decisions.md        — Architecture decision records
.titan/docs/design/module-specs/       — Per-module specifications
.titan/docs/domain/                    — Domain-specific reference
.titan/prompts/coding-agent.md         — Coding agent session prompt
.titan/prompts/initializer-agent.md    — Bootstrap session prompt
.titan/scripts/init.sh                 — Idempotent environment setup (generated)
```

### Phase 6 — Autonomous Loop Engine
```
.titan/core/loop-controller.md         — Loop controller specification
.titan/core/e2e-verification.md        — E2E verification strategies
.titan/core/trigger-engine.md          — Trigger system specification
.titan/core/tooling-philosophy.md      — Generic tooling guidelines
.titan/core/enforcement.md             — Architectural enforcement guide
.titan/scripts/titan-loop.sh           — Loop controller shell script
.titan/triggers/                       — Trigger definitions directory
.titan/enforcement/pre-commit          — Git pre-commit hook
.titan/enforcement/structural-tests/   — Structural test suite
.titan/enforcement/architecture-rules.json — Dependency + boundary rules
.titan/templates/ESCALATION-REPORT.md  — Escalation report template
.titan/templates/MANIFEST-ENTRY.json   — Feature entry template
.titan/templates/TRIGGER.json          — Trigger definition template
.titan/core/knowledge-store.md         — Knowledge store specification (optional)
.titan/scripts/knowledge-store.sh      — Knowledge store setup + ingest script (optional)
.titan/knowledge.db                    — SQLite + sqlite-vec database (generated, optional)
```

---

## Modified Files Summary

| File | Modification |
|------|-------------|
| `titan/commands/init.md` | Check for bootstrap, skip to coding-agent mode if present |
| `titan/commands/build.md` | Integrate E2E verification call after build |
| `titan/commands/verify.md` | Add E2E verification layer on top of oracle loop |
| `titan/core/orchestrator.md` | Add loop controller awareness, session orientation |
| All 9 agent definitions | Add "Tooling Preference" section (bash-first) |
| `titan/core/state.md` | Add MANIFEST.json + LOOP-STATE.json schemas |
| `titan/commands/audit.md` | Add staleness detection for progressive docs |
| `titan/commands/handoff.md` | Auto-generate from LOOP-STATE instead of manual |
| `titan/templates/project-structure.md` | Add all new directories and files |
| `titan/core/golden-path.md` | Insert bootstrap as Step 0, loop as post-Step 8 |

---

## Implementation Order

**Prerequisites:** v1.1 Phases 1–4 should be implemented first. The autonomous loop layer depends on the loop governor (Upgrade 8), context budget manager (Upgrade 3), and session handoff protocol (Upgrade 11) as foundations.

### Phase 5 — Legible Environment
```
5A. Upgrade 12: Initializer Agent Pattern
    → Creates the scaffold everything else depends on
5B. Upgrade 14: Progressive Documentation System
    → Establishes docs architecture before sessions populate it
5C. Upgrade 13: Session Orientation Protocol
    → Wires up the orientation sequence that uses the scaffold
```

### Phase 6 — Autonomous Loop Engine
```
6A. Upgrade 15: End-to-End Verification Harness
    → Must exist before the loop can verify its own work
6B. Upgrade 19: Architectural Enforcement Layer
    → Mechanical guardrails must exist before unsupervised looping
6C. Upgrade 16: Autonomous Loop Controller
    → The core loop, built on top of verification + enforcement
6D. Upgrade 17: Trigger Engine
    → Extends the loop with reactive capabilities
6E. Upgrade 18: Generic Tooling Philosophy
    → Can be applied incrementally as agents are modified
6F. Upgrade 20: Local Semantic Knowledge Store (OPTIONAL)
    → Only after loop is running and generating session history to index
    → Can be added at any time — system works without it
```

---

## Design Principles

These principles synthesize the convergent learnings from Anthropic, OpenAI, Vercel, and OpenClaw:

1. **The environment IS the prompt.** Documentation, file structure, git history, and enforcement rules collectively tell the agent what to do. The session prompt is just the nudge.

2. **Incremental over one-shot.** One feature per session. Always. The agent that tries to build everything at once will fail in the middle and leave a mess.

3. **Verify like a user, not like a compiler.** Unit tests are necessary but not sufficient. End-to-end testing (actually running the app) catches the bugs that matter.

4. **Clean state is non-negotiable.** Every session ends with committable code. No exceptions. The next session should never inherit a mess.

5. **JSON for state, Markdown for humans.** Machine-readable state (MANIFEST, LOOP-STATE) uses JSON. Human-readable logs and docs use Markdown. The model is less likely to corrupt JSON.

6. **Generic tools over bespoke wrappers.** Bash, git, grep, and standard CLI tools have billions of training tokens. Bespoke JSON tool-calling schemas have zero. Use what the model knows.

7. **Mechanical enforcement over prompt engineering.** Pre-commit hooks can't be sweet-talked. Linters don't hallucinate. Use deterministic checks for deterministic rules.

8. **Escalate, don't spin.** Three failures on the same problem means the agent needs a human. Looping further wastes tokens and compounds the mess.

9. **The repository is the single source of truth.** If the agent can't access it in the environment, it effectively doesn't exist. Push everything (docs, specs, context) into the repo.

10. **Trust the model.** Given the right environment, verification tools, and enforcement rails, frontier models can autonomously ship features. The harness makes this possible — not the prompt.

---

## Relationship to FORGE Routing

TITAN v2.0's autonomous loop integrates with the existing FORGE-derived routing logic:

- **In-session execution** (DSP-heavy work) → Single coding-agent session, extended context
- **Parallel execution** (UI components) → Loop controller can run multiple feature tracks
- **TIER-3 escalation** (frontier API) → Loop controller can switch model tiers mid-loop based on failure patterns

The loop controller respects the Model Tier Routing System (v1.1 Upgrade 1) — it will automatically escalate to TIER-3 if TIER-1 fails on a feature, before escalating to the user.

---

## Success Metrics

When fully implemented, TITAN v2.0 should enable:

- **Overnight autonomous runs:** Start `/titan:loop-start` before bed, wake up to 3–8 features implemented and verified
- **Minimal human intervention:** Escalation rate < 20% of features (80%+ completed without human input)
- **Zero regression rate:** Architectural enforcement + E2E verification prevents passing features from breaking
- **Clean handoffs:** Any session (human or autonomous) can pick up exactly where the last one left off within 30 seconds of orientation
- **Compound velocity:** Each completed feature makes the next one easier because the environment, docs, and test suite grow richer

---

*"The model today is actually much more powerful than you think — as long as you design the right system to unlock it."*

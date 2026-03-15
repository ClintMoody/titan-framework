# Initializer Agent Pattern

## Purpose

The Initializer Agent is a one-time bootstrap routine that transforms a raw project into a TITAN-managed autonomous development loop. It runs during `/titan:00-bootstrap` and produces every artifact the coding agent needs to begin iterating without human guidance.

The Initializer Agent answers one question: **"What does this project need to become, and what does the machine need to build it?"**

---

## When It Runs

- Triggered by `/titan:00-bootstrap` on first run
- Re-runnable safely (all outputs are idempotent)
- Should complete in a single session
- Requires: project source (or empty repo), a vision statement or README describing what the project will become

## Inputs

| Input | Source | Required |
|---|---|---|
| Project vision / README | User-provided or existing repo | Yes |
| Existing source code | Repository root | No (greenfield OK) |
| Tech stack preferences | User-provided or inferred | No |
| Domain context | User-provided | No |

The Initializer reads everything available in the repo to understand the project's current state. It then synthesizes a complete development plan from the vision.

---

## Outputs

The Initializer produces five artifacts. Each is described in detail below.

### 1. `init.sh` — Environment Setup Script

**Location:** Project root (`./init.sh`)

A shell script that brings any machine from zero to a working dev environment. It must be:

- **Idempotent.** Running it twice produces the same result as running it once. Every operation checks before acting.
- **Non-destructive.** It never deletes data, drops databases without backup, or overwrites user config.
- **Verbose.** Every step prints what it is doing so failures are diagnosable.
- **Exit-on-error.** Uses `set -euo pipefail` to halt on any failure.

**Required sections (in order):**

```
1. Check prerequisites (runtime versions, system dependencies)
2. Install project dependencies (npm install, pip install, cargo build, etc.)
3. Set up environment files (.env from .env.example, with sane defaults)
4. Run database migrations (if applicable)
5. Seed development data (if applicable)
6. Start required services (databases, message queues, etc.)
7. Run smoke test to verify environment health
8. Print success banner with "environment ready" confirmation
```

**Rules for init.sh:**

- Must work on macOS and Linux (use `uname` checks where needed)
- Must not require `sudo` unless absolutely necessary (and must explain why)
- Must use package lockfiles (package-lock.json, Pipfile.lock, Cargo.lock) if they exist
- Must set up `.env` from `.env.example` only if `.env` does not already exist
- Smoke test at the end must be a real health check (HTTP ping, test suite, or build verification), not just `echo "done"`

**Example structure:**

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== TITAN Environment Initialization ==="

# 1. Prerequisites
command -v node >/dev/null 2>&1 || { echo "ERROR: Node.js required"; exit 1; }
NODE_VERSION=$(node -v | sed 's/v//')
echo "✓ Node.js $NODE_VERSION"

# 2. Dependencies
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi
echo "✓ Dependencies installed"

# 3. Environment
if [ ! -f .env ]; then
  cp .env.example .env
  echo "✓ .env created from .env.example"
else
  echo "✓ .env already exists (skipped)"
fi

# ... (migrations, seeds, services)

# 7. Smoke test
npm test -- --bail 2>/dev/null || { echo "ERROR: Smoke test failed"; exit 1; }
echo "✓ Smoke test passed"

echo ""
echo "=== Environment Ready ==="
```

---

### 2. `.titan/MANIFEST.json` — Feature Manifest

**Location:** `.titan/MANIFEST.json`

The MANIFEST is the single source of truth for what the project must become. It is a JSON array of feature definitions extracted from the project vision.

**Feature schema:**

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

**Field definitions:**

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier. Format: `F-NNN` (zero-padded, sequential) |
| `category` | string | One of: `core`, `ui`, `api`, `infra`, `integration`, `polish`, `security` |
| `description` | string | User-visible behavior. Written as "User can..." or "System does..." |
| `acceptance_criteria` | string[] | Testable conditions. Each must be verifiable by a machine or human. |
| `priority` | integer | 1 = highest. Lower numbers are built first. |
| `status` | string | One of: `failing`, `passing`, `blocked` |
| `dependencies` | string[] | Array of feature IDs that must be `passing` before this one can begin |
| `estimated_sessions` | integer | How many coding-agent sessions this feature likely requires |

**Rules for the MANIFEST:**

> **It is unacceptable to remove or edit feature definitions. Only the `status` field may be changed, and only after end-to-end verification.**

This rule exists because:
- LLMs are prone to "simplifying" by removing features they find complex
- A shrinking MANIFEST is an undetectable regression — the project looks "done" while missing capabilities
- The MANIFEST is a contract with the project vision, not a suggestion list

**Additional MANIFEST rules:**

1. **All features start as `"failing"`.** No exceptions. Even if existing code partially implements a feature, it starts as failing until verified end-to-end.
2. **JSON format is mandatory.** JSON is used instead of Markdown because models are significantly less likely to corrupt structured JSON. Markdown tables are fragile under LLM editing.
3. **Acceptance criteria must be testable.** Vague criteria like "works well" or "looks good" are not acceptable. Each criterion must have a binary pass/fail evaluation.
4. **Priority ordering must respect dependencies.** A feature cannot have a higher priority (lower number) than its dependencies.
5. **Session estimates must be conservative.** When uncertain, round up. A 1-session estimate means the feature is straightforward; 3+ means it involves multiple subsystems.
6. **Category assignment drives agent routing.** The category determines which documentation partitions the coding agent receives during implementation.

**Priority assignment guidelines:**

| Priority Range | Meaning |
|---|---|
| 1-5 | Foundation — without these, nothing else works |
| 6-15 | Core functionality — the product's primary value |
| 16-30 | Supporting features — important but not load-bearing |
| 31-50 | Polish and integration — quality-of-life improvements |
| 51+ | Nice-to-have — implement if time permits |

**Session estimation guidelines:**

| Estimate | Typical Scope |
|---|---|
| 1 session | Single file change, straightforward logic, clear pattern to follow |
| 2 sessions | Multiple files, some design decisions, moderate test coverage |
| 3 sessions | Cross-cutting concern, new subsystem, complex state management |
| 4-5 sessions | Major feature with UI + API + data layer, significant test infrastructure |
| 5+ sessions | Should be broken into smaller features |

---

### 3. `.titan/PROGRESS.md` — Session Log

**Location:** `.titan/PROGRESS.md`

An append-only log that records every coding-agent session. This file is never edited retroactively — only new entries are appended.

**File structure:**

```markdown
# TITAN Progress Log

## Session 1 — 2026-03-15

- **Model:** claude-sonnet-4-6
- **Feature:** F-001 — User can create a new project with audio file import
- **Status:** passing
- **Changes:**
  - Created `src/project/create.ts` with file import logic
  - Added `FileImporter` component with drag-and-drop support
  - Created test suite `tests/project/create.test.ts`
- **Commits:**
  - `a1b2c3d` titan(build): implement project creation with audio import
- **Verification:** All 4 acceptance criteria verified end-to-end
- **Next Priority:** F-002 — Audio waveform display
- **Environment State:** green

---

## Session 2 — 2026-03-15

...
```

**Rules for PROGRESS.md:**

1. **Append-only.** Never modify previous entries.
2. **Every session gets an entry.** Even sessions that only fixed bugs and made no feature progress.
3. **Honest status reporting.** If a feature is not fully verified, the status is `failing` regardless of how much code was written.
4. **Environment state** must reflect the actual result of `init.sh` + smoke test at session start.

---

### 4. `.titan/docs/` — Documentation Architecture

**Location:** `.titan/docs/`

The Initializer creates the documentation scaffold that the Progressive Documentation System (see `core/progressive-docs.md`) will maintain throughout the project.

**Directory structure created:**

```
.titan/docs/
├── INDEX.md              ← Table of contents for all documentation
├── architecture.md       ← System architecture overview
├── design/
│   ├── module-specs/     ← Per-module specifications (empty initially)
│   └── decisions.md      ← Architectural Decision Record log
├── execution-plan.md     ← Current build plan (populated from MANIFEST)
├── quality.md            ← Quality grades per domain
└── domain/               ← Domain-specific reference material (empty initially)
```

**INDEX.md** is the entry point. It lists every document with a one-line summary and last-updated session number. Agents read INDEX.md first to find what they need.

**architecture.md** contains:
- System overview diagram (ASCII or Mermaid)
- Component boundaries
- Data flow
- External integrations
- Key technology choices with rationale

**decisions.md** follows the ADR (Architectural Decision Record) format:
- Each decision has a number, title, context, decision, and consequences
- Decisions are never deleted, only superseded

**execution-plan.md** translates the MANIFEST priorities into a linear build order, grouping related features into phases.

**quality.md** tracks quality grades per project domain:
- Grades: A (excellent), B (good), C (adequate), D (needs work), F (failing), STALE (not maintained)
- Updated by the verification agent after each session

---

### 5. Initial Git Commit

The Initializer creates one clean commit containing all generated artifacts:

```
titan(bootstrap): initialize TITAN development loop

- Generated init.sh (environment setup)
- Created MANIFEST.json (N features extracted from vision)
- Created PROGRESS.md (session log)
- Scaffolded .titan/docs/ documentation architecture
```

This commit is the project's "time zero" for the autonomous loop.

---

## Initializer Lifecycle

The full sequence of the Initializer Agent:

```
1. READ PHASE
   ├── Read project README / vision document
   ├── Read all existing source files (scan repo)
   ├── Read package manifests (package.json, Cargo.toml, etc.)
   ├── Read existing tests (if any)
   └── Read existing CI/CD configuration (if any)

2. ANALYZE PHASE
   ├── Identify tech stack and toolchain
   ├── Identify existing features (if any code exists)
   ├── Decompose vision into discrete features
   ├── Map feature dependencies
   └── Estimate session counts

3. GENERATE PHASE
   ├── Write init.sh
   ├── Write .titan/MANIFEST.json
   ├── Write .titan/PROGRESS.md (with Session 0 entry)
   ├── Scaffold .titan/docs/ structure
   └── Write .titan/AGENTS.md (table-of-contents, see progressive-docs.md)

4. VERIFY PHASE
   ├── Run init.sh to verify it works
   ├── Validate MANIFEST.json is valid JSON
   ├── Validate all feature IDs are unique
   ├── Validate dependency graph has no cycles
   └── Validate priority ordering respects dependencies

5. COMMIT PHASE
   ├── Stage all generated files
   ├── Create initial commit
   └── Log bootstrap completion in PROGRESS.md
```

---

## Handoff to the Coding Agent

After the Initializer completes, the coding agent takes over using the Session Orientation Protocol (see `core/session-orientation.md`). The handoff is implicit — the next session reads `.titan/PROGRESS.md` and `.titan/MANIFEST.json` and begins working on the highest-priority failing feature.

**What the coding agent inherits:**

| Artifact | Purpose for Coding Agent |
|---|---|
| `init.sh` | Run at session start to verify environment health |
| `MANIFEST.json` | Source of truth for what to build next |
| `PROGRESS.md` | Context on what happened in previous sessions |
| `.titan/docs/` | Reference material for implementation decisions |
| `LOOP-STATE.json` | Machine-readable loop position (created by first coding session) |

**The Initializer's job is done when:**

1. `init.sh` runs successfully and the smoke test passes
2. `MANIFEST.json` contains at least one feature with `priority: 1`
3. `PROGRESS.md` has a Session 0 (bootstrap) entry
4. `.titan/docs/INDEX.md` exists and lists all documentation files
5. All artifacts are committed to git

The coding agent must never need to ask "what should I build?" — the MANIFEST answers that question permanently.

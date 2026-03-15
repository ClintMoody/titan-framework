---
name: titan:00-bootstrap
description: First-run initializer — creates autonomous scaffold for multi-session work
---

# /titan:00-bootstrap — Autonomous Bootstrap

> Run this command once to create the autonomous development scaffold. This is Step 0 of the Golden Path — it generates everything needed for multi-session, loop-driven development.

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` first or combine with it).
- `.titan/MANIFEST.json` does **NOT** exist yet.

If `.titan/MANIFEST.json` already exists, print:
```
⚠ Bootstrap already complete.
  MANIFEST.json found with [N] features ([X] passing, [Y] failing).
  Use /titan:loop-start to begin autonomous development or /titan:resume to continue.
```
And stop.

## Process

### Step 1: Display Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — AUTONOMOUS BOOTSTRAP                             ║
╚══════════════════════════════════════════════════════════════╝

  Creating autonomous scaffold for multi-session work.
  This runs once — everything needed for loop-driven
  development will be generated.
```

### Step 2: Read Project Foundation Documents

Read the following files to build a comprehensive understanding of the project:

- `PROJECT.md` — project overview and goals
- `REQUIREMENTS.md` — functional and non-functional requirements
- `ARCHITECTURE.md` — technical architecture and system design
- `ROADMAP.md` — development phases and milestones

If any file is missing, warn the user:
```
⚠ Missing: [filename]
  Bootstrap works best with all foundation documents.
  Consider running /titan:02-vision first to generate them.
```

If `PROJECT.md` AND `REQUIREMENTS.md` are both missing, stop:
```
✗ Cannot bootstrap without PROJECT.md and REQUIREMENTS.md.
  Run /titan:02-vision to define your project first.
```

### Step 3: Generate init.sh

Create `init.sh` at the project root — an idempotent environment setup script.

Detect the tech stack from project files and foundation documents. Generate appropriate commands:

| Detected Stack | Commands |
|---------------|----------|
| Node.js | `npm install` (or `yarn install`, `pnpm install`) |
| Python | `pip install -r requirements.txt` or `poetry install` |
| Rust | `cargo build` |
| Go | `go mod download` |
| Ruby | `bundle install` |
| Java/Kotlin | `./gradlew build` or `mvn install` |

The script MUST be:
- **Idempotent** — re-runnable without side effects
- **Guarded** — check for prerequisites before running each command
- **Logged** — print what it's doing at each step
- **Error-tolerant** — continue on non-critical failures, fail on critical ones

Mark as executable: `chmod +x init.sh`

### Step 4: Generate .titan/MANIFEST.json

Derive every feature from `PROJECT.md` and `REQUIREMENTS.md`. Structure:

```json
{
  "version": "2.0",
  "generated": "[ISO 8601 timestamp]",
  "project": "[project name]",
  "phases": [
    {
      "phase": 1,
      "name": "[from ROADMAP.md]",
      "features": [
        {
          "id": "F-001",
          "category": "[feature category]",
          "description": "[clear feature description]",
          "acceptance_criteria": [
            "[criterion 1]",
            "[criterion 2]"
          ],
          "priority": 1,
          "status": "failing",
          "dependencies": [],
          "estimated_sessions": 1
        }
      ]
    }
  ],
  "totals": {
    "features": 0,
    "passing": 0,
    "failing": 0,
    "estimated_sessions": 0
  }
}
```

Rules:
- Feature IDs are sequential: F-001, F-002, F-003...
- ALL features start as `"failing"` — nothing is assumed working
- Group features by ROADMAP phases
- Priority 1 = highest, 5 = lowest
- Dependencies reference other feature IDs (e.g., `["F-001", "F-003"]`)
- `estimated_sessions` is a rough estimate per feature (1-5)
- Include a `// MANIFEST GUARD — do not edit manually` comment in the file header

### Step 5: Initialize .titan/PROGRESS.md

Write `.titan/PROGRESS.md`:

```markdown
# TITAN Progress Log

> Autonomous session-by-session progress tracking.

## Session 0 — Bootstrap

- **Date:** [ISO 8601 timestamp]
- **Action:** Autonomous scaffold created
- **Features Generated:** [count]
- **Estimated Total Sessions:** [sum of estimated_sessions]
- **Status:** Ready for autonomous development

---
```

### Step 6: Initialize .titan/LOOP-STATE.json

Write `.titan/LOOP-STATE.json`:

```json
{
  "version": "2.0",
  "session": 0,
  "status": "ready",
  "current_feature": null,
  "last_completed_feature": null,
  "consecutive_failures": 0,
  "escalation": null,
  "started_at": null,
  "updated_at": "[ISO 8601 timestamp]",
  "history": []
}
```

### Step 7: Create .titan/docs/ Structure

Create the documentation tree:

```
.titan/docs/
├── INDEX.md
├── architecture.md
├── execution-plan.md
├── quality.md
├── design/
│   └── decisions.md
└── domain/
    └── README.md
```

Populate:
- `INDEX.md` — table of contents linking to all docs
- `architecture.md` — populated from `ARCHITECTURE.md` content
- `execution-plan.md` — populated from `ROADMAP.md` content
- `quality.md` — initial quality grades (all "Pending")
- `design/decisions.md` — populated from `DECISIONS.md` if it exists, otherwise seeded with header
- `domain/README.md` — domain-specific notes from config.yaml domain plugin

### Step 8: Create .titan/prompts/coding-agent.md

Write the session prompt for autonomous coding sessions. This prompt instructs a coding agent how to:
- Read LOOP-STATE.json to determine current feature
- Read MANIFEST.json for feature details and acceptance criteria
- Implement the feature
- Run verification
- Update MANIFEST.json status
- Update PROGRESS.md
- Commit changes
- Advance to next feature or escalate on failure

### Step 9: Create .titan/prompts/initializer-agent.md

Write a copy of this bootstrap prompt — a reference for future re-initialization or debugging.

### Step 10: Generate .titan/AGENTS.md

Write `.titan/AGENTS.md` — the v2.0 table-of-contents format (~100 lines). This file maps agent roles to their capabilities, the commands they serve, and when they're invoked. Structure:

```markdown
# TITAN v2.0 — Agent Directory

> Maps each agent to its role, capabilities, and invocation triggers.

| Agent | Role | Commands | Trigger |
|-------|------|----------|---------|
| titan-designer | Architecture & design | 04-design, refactor | Design phases |
| titan-executor | Implementation | 06-build, quick | Build phases |
| titan-investigator | Deep analysis | investigate, debug | On-demand |
| titan-optimizer | Performance | audit (perf) | Audit, review |
| titan-researcher | Research & learning | 03-explore, learn | Explore phases |
| titan-security | Security analysis | audit (security), scan | Audit, build |
| titan-strategist | Planning & roadmap | 02-vision, 05-plan | Planning phases |
| titan-tester | Test & verification | 07-verify, test | Verify phases |
| titan-verifier | Acceptance testing | verify-e2e, loop | Loop verification |
...
```

### Step 11: Git Commit

Stage and commit all generated files:

```
titan(bootstrap): autonomous scaffold created
```

### Step 12: Display Completion Summary

Print (as markdown, NOT in a code block):

---

## ✓ TITAN — AUTONOMOUS BOOTSTRAP COMPLETE

| Metric | Value |
|--------|-------|
| **Features Derived** | [count from MANIFEST.json] |
| **Phases** | [count from MANIFEST.json] |
| **Estimated Sessions** | [sum of estimated_sessions] |
| **Total Scope** | [brief summary] |

**Created:**

| Status | File | Purpose |
|--------|------|---------|
| ✓ | `init.sh` | Idempotent environment setup |
| ✓ | `.titan/MANIFEST.json` | Feature manifest (all failing) |
| ✓ | `.titan/PROGRESS.md` | Session progress log |
| ✓ | `.titan/LOOP-STATE.json` | Loop controller state |
| ✓ | `.titan/docs/` | Documentation tree |
| ✓ | `.titan/prompts/` | Agent prompts |
| ✓ | `.titan/AGENTS.md` | Agent directory |

Step 0 of Golden Path ▓▓░░░░░░░░░░░░░░ Ready

---

### ★ Recommended

> Run `/titan:loop-start` to begin autonomous development, or `/titan:05-plan` for manual phase-by-phase work.

### Other options

| Command | Action |
|---------|--------|
| `/titan:loop-status` | Check loop readiness before starting |
| `/titan:05-plan` | Plan manually instead of autonomous loop |
| `/titan:progress` | View the full project dashboard |

---

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| init.sh | `./init.sh` | Idempotent environment setup script |
| MANIFEST.json | `.titan/MANIFEST.json` | Complete feature manifest |
| PROGRESS.md | `.titan/PROGRESS.md` | Session-by-session progress log |
| LOOP-STATE.json | `.titan/LOOP-STATE.json` | Loop controller state |
| docs/ | `.titan/docs/` | Documentation tree |
| prompts/ | `.titan/prompts/` | Agent session prompts |
| AGENTS.md | `.titan/AGENTS.md` | v2.0 agent directory |

## State Updates

After this command completes:
- STATE.md step → "bootstrap (complete)"
- STATE.md Next Action → "/titan:loop-start or /titan:05-plan"

## Error Handling

| Error | Resolution |
|-------|-----------|
| `MANIFEST.json` already exists | Inform user, suggest `/titan:loop-start` or `/titan:resume` |
| `PROJECT.md` missing | Direct user to `/titan:02-vision` |
| `REQUIREMENTS.md` missing | Direct user to `/titan:02-vision` |
| `ROADMAP.md` missing | Generate single-phase manifest, warn about limited scope |
| `ARCHITECTURE.md` missing | Skip docs/architecture.md population, warn |
| Git commit fails | Continue without commit, warn user |
| Parse errors in foundation docs | Best-effort extraction, flag ambiguous features for review |

## Tips

- Bootstrap only runs once. If you need to regenerate the manifest, delete `.titan/MANIFEST.json` and re-run.
- The manifest is the source of truth for autonomous development. Review it after bootstrap to ensure features are correctly derived.
- `init.sh` should be committed to version control — it helps other contributors (or future sessions) set up quickly.
- If the estimated session count seems high, consider splitting large features or reducing scope in `REQUIREMENTS.md`.
- The prompts in `.titan/prompts/` can be customized — they're templates, not sacred text.

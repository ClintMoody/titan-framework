# Progressive Documentation System

## Purpose

The Progressive Documentation System replaces flat, monolithic knowledge files with a structured table-of-contents architecture that scales with the project. Instead of one massive CLAUDE.md or AGENTS.md that every agent must parse in full, documentation is partitioned by concern and agents receive only the slices relevant to their task.

This system solves three problems:
1. **Context bloat.** Large knowledge files waste LLM context window on irrelevant information.
2. **Staleness.** Flat files become stale because nobody owns them and staleness is invisible.
3. **Inconsistency.** When everything is in one file, updates to one section silently contradict another section.

---

## Architecture Overview

```
.titan/
├── AGENTS.md                 ← Small TOC (~100 lines), entry point for all agents
├── MANIFEST.json             ← Feature list (see initializer-agent.md)
├── PROGRESS.md               ← Session log (see session-orientation.md)
├── LOOP-STATE.json           ← Loop position (see session-orientation.md)
└── docs/
    ├── INDEX.md              ← Master table of contents
    ├── architecture.md       ← System architecture
    ├── design/
    │   ├── module-specs/     ← Per-module specifications
    │   │   ├── auth.md
    │   │   ├── audio-engine.md
    │   │   └── ...
    │   └── decisions.md      ← Architectural Decision Record log
    ├── execution-plan.md     ← Current build plan by phase
    ├── quality.md            ← Quality grades per domain
    └── domain/               ← Domain-specific reference material
        ├── audio-formats.md
        ├── midi-spec.md
        └── ...
```

---

## Component Specifications

### 1. `.titan/AGENTS.md` — Agent Table of Contents

**Size target:** ~100 lines. No more.

AGENTS.md is the first file any agent reads. It provides just enough context to orient the agent and tells it where to find deeper information. It is NOT a comprehensive knowledge base.

**Required sections:**

```markdown
# TITAN Agent Orientation

## Quick Orientation
- Project: [name]
- Stack: [technologies]
- Current phase: [phase description]
- Features passing: [N] / [total]

## Active Constraints
- [Constraint 1 — e.g., "No external API calls in tests"]
- [Constraint 2 — e.g., "All components must support dark mode"]
- [Constraint 3 — e.g., "Database migrations must be reversible"]

## Working Agreements
- Commit format: titan([scope]): [description]
- Test requirement: Every acceptance criterion must have a test
- Documentation: Update module-spec when changing public interfaces

## Documentation Map
| Document | Path | Purpose |
|---|---|---|
| Architecture | .titan/docs/architecture.md | System design, boundaries, data flow |
| Module Specs | .titan/docs/design/module-specs/ | Per-module interfaces and contracts |
| Decisions | .titan/docs/design/decisions.md | Why we chose X over Y |
| Build Plan | .titan/docs/execution-plan.md | What to build in what order |
| Quality | .titan/docs/quality.md | Quality grades and known issues |
| Domain Ref | .titan/docs/domain/ | Domain-specific knowledge |
```

**Rules for AGENTS.md:**

1. Must stay under 100 lines. If it grows beyond that, content must be moved to a deeper document.
2. Active Constraints section is limited to 5 items. If more are needed, create `.titan/docs/constraints.md` and link to it.
3. Updated by the Initializer on bootstrap and by agents when project-wide constraints change.
4. Never contains implementation details — only orientation and pointers.

---

### 2. `.titan/docs/INDEX.md` — Master Table of Contents

INDEX.md is the directory listing for all documentation. Every document in `.titan/docs/` must be registered here.

**Format:**

```markdown
# Documentation Index

Last updated: Session 14

| Document | Path | Last Updated | Summary |
|---|---|---|---|
| Architecture | architecture.md | Session 3 | System overview, components, data flow |
| Auth Module | design/module-specs/auth.md | Session 8 | Authentication flows, token management |
| Audio Engine | design/module-specs/audio-engine.md | Session 12 | Audio processing pipeline, format support |
| Decisions | design/decisions.md | Session 14 | ADR log (12 decisions recorded) |
| Build Plan | execution-plan.md | Session 10 | Phase breakdown, current: Phase 3 |
| Quality | quality.md | Session 14 | Overall: B, lowest domain: C (error handling) |
| Audio Formats | domain/audio-formats.md | Session 5 | WAV/AIFF/FLAC specs and parsing rules |
```

**Rules for INDEX.md:**

1. Every document must appear here. An unindexed document is effectively invisible.
2. "Last Updated" is the session number, not a date. This enables staleness detection.
3. Updated whenever any document is created, renamed, or significantly modified.

---

### 3. `.titan/docs/architecture.md` — System Architecture

The single-source-of-truth for how the system is structured.

**Required sections:**

```markdown
# System Architecture

## Overview
[2-3 sentence description of the system]

## System Diagram
[ASCII or Mermaid diagram showing major components and their relationships]

## Components

### [Component Name]
- **Responsibility:** [what it does]
- **Boundary:** [what it does NOT do]
- **Key interfaces:** [public API surface]
- **Dependencies:** [what it depends on]
- **Module spec:** [link to .titan/docs/design/module-specs/X.md]

### [Next Component]
...

## Data Flow
[How data moves through the system — request lifecycle, event flow, etc.]

## External Integrations
[Third-party services, APIs, databases with connection details]

## Technology Choices
| Choice | Rationale | Alternatives Considered |
|---|---|---|
| [Tech] | [Why] | [What else was evaluated] |
```

**Rules for architecture.md:**

1. Must be updated whenever a new component is added or component boundaries change.
2. The System Diagram must stay in sync with the Components section.
3. Technology choices must link to the relevant ADR in decisions.md.

---

### 4. `.titan/docs/design/module-specs/` — Module Specifications

Each significant module gets its own spec file. A module is "significant" if it has a public interface used by other modules.

**Module spec template:**

```markdown
# Module: [Name]

## Purpose
[What this module does and why it exists]

## Public Interface

### [Function/Method/Endpoint]
- **Signature:** [full signature]
- **Parameters:** [description of each]
- **Returns:** [what it returns]
- **Throws/Errors:** [error conditions]
- **Example:** [usage example]

## Internal Design
[How the module works internally — data structures, algorithms, state management]

## Dependencies
- [Module X] — [why it's needed]
- [External library] — [why it's needed]

## Testing
- **Unit tests:** [path to test file]
- **Integration tests:** [path or description]
- **Key test scenarios:** [list of critical scenarios covered]

## Quality Notes
- **Current grade:** [from quality.md]
- **Known issues:** [any known problems]
- **Tech debt:** [any shortcuts taken]
```

**Rules for module-specs:**

1. Created when a module is first implemented.
2. Updated when a module's public interface changes.
3. The Public Interface section is the contract — if the implementation diverges from the spec, the implementation is wrong (unless the spec is updated first via a decision in decisions.md).

---

### 5. `.titan/docs/design/decisions.md` — Architectural Decision Records

Tracks every significant design decision using the ADR format.

**Entry format:**

```markdown
## ADR-001: [Title]

- **Date:** Session N
- **Status:** accepted | superseded by ADR-NNN | deprecated
- **Context:** [What situation prompted this decision]
- **Decision:** [What was decided]
- **Consequences:** [What follows from this decision — both positive and negative]
```

**Rules for decisions.md:**

1. Decisions are never deleted. A bad decision is marked `superseded` with a link to the replacement.
2. Any change to architecture.md should have a corresponding ADR.
3. Agents should check decisions.md before making choices that contradict existing decisions.

---

### 6. `.titan/docs/execution-plan.md` — Build Plan

Translates MANIFEST.json priorities into a phased execution plan.

**Format:**

```markdown
# Execution Plan

## Current Phase: Phase 3 — Core Audio Features

## Phase Summary
| Phase | Features | Status |
|---|---|---|
| Phase 1: Foundation | F-001 to F-005 | Complete |
| Phase 2: Basic UI | F-006 to F-012 | Complete |
| Phase 3: Core Audio | F-013 to F-025 | In Progress (8/13) |
| Phase 4: Integrations | F-026 to F-035 | Not Started |
| Phase 5: Polish | F-036 to F-047 | Not Started |

## Phase 3 Details

### Completed
- F-013: Audio playback engine (Session 8)
- F-014: Waveform rendering (Session 9)
...

### In Progress
- F-023: WAV export (current session)

### Remaining
- F-024: Batch export
- F-025: Audio effects pipeline
```

**Rules for execution-plan.md:**

1. Updated when features change status (at checkpoint).
2. Phase groupings are set at bootstrap and rarely change.
3. Must stay consistent with MANIFEST.json — if they diverge, MANIFEST.json is authoritative.

---

### 7. `.titan/docs/quality.md` — Quality Grades

Tracks quality assessment per project domain.

**Format:**

```markdown
# Quality Assessment

Last updated: Session 14

## Overall Grade: B

## Domain Grades

| Domain | Grade | Notes | Last Assessed |
|---|---|---|---|
| Authentication | A | Full test coverage, no known issues | Session 12 |
| Audio Engine | B | Good coverage, one edge case pending (F-021) | Session 14 |
| UI Components | B | Responsive, accessible, needs dark mode polish | Session 11 |
| Data Persistence | C | Works but migration rollback untested | Session 9 |
| Error Handling | C | Happy path solid, edge cases incomplete | Session 8 |
| API Layer | B | RESTful, validated, needs rate limiting | Session 13 |
| Documentation | STALE | architecture.md not updated since Session 3 | Session 14 |

## Staleness Flags

| Document | Last Updated | Current Session | Gap | Status |
|---|---|---|---|---|
| architecture.md | Session 3 | Session 14 | 11 sessions | STALE |
| domain/audio-formats.md | Session 5 | Session 14 | 9 sessions | At risk |

## Action Items
1. **STALE: architecture.md** — Has not been updated in 11 sessions. Likely outdated. Needs review and refresh.
2. **At risk: audio-formats.md** — Approaching staleness threshold. Review during next audio-related session.
```

**Grade definitions:**

| Grade | Meaning |
|---|---|
| A | Excellent — comprehensive tests, no known issues, well-documented |
| B | Good — solid coverage, minor issues known and tracked |
| C | Adequate — works for current needs but has known gaps |
| D | Needs Work — significant gaps, tech debt accumulating |
| F | Failing — broken or severely deficient |
| STALE | Not Maintained — document or domain not updated in 10+ sessions |

---

## Staleness Prevention

The staleness prevention system ensures documentation does not silently rot.

### Detection Triggers

Staleness scans run:
1. During session orientation (Step 1) — lightweight check of LOOP-STATE.json session number vs INDEX.md last-updated values
2. During `/titan:audit` — comprehensive scan
3. During checkpoint (Step 5) — if the session modified code in a module, check if the corresponding module-spec was also updated

### Staleness Criteria

A document is flagged as **STALE** when any of these conditions are true:

| Condition | Detection Method |
|---|---|
| Not modified in 10+ sessions | Compare INDEX.md "Last Updated" session number to current session |
| References deleted code | Grep document for function/class names, check if they still exist in source |
| Broken cross-references | Check that all `[link](path)` references in the document resolve to existing files |
| Contradicts current architecture | Compare architecture.md component list against actual source directory structure |

### Staleness Response

When stale documents are detected:

```
1. Flag the document in quality.md with STALE grade
2. Add the document to the Staleness Flags table
3. Log the staleness in PROGRESS.md
4. If the stale document is a module-spec for a module being actively developed:
   → Update it in the current session (takes priority over new features)
5. If the stale document is not blocking current work:
   → Add it as an action item for the next available session
```

### Pre-Staleness Warning

Documents that have not been updated in 7-9 sessions are flagged as **"At risk"** in quality.md. This gives agents a chance to update them proactively before they become formally stale.

---

## Knowledge Partitioning for Agents

Different agents need different documentation. Loading irrelevant docs wastes context and can confuse the agent. The partitioning table defines which docs each agent receives.

### Partitioning Table

| Agent | Documents Loaded | Rationale |
|---|---|---|
| **Executor** | architecture.md, relevant module-spec, execution-plan.md | Needs to understand system structure, module contract, and current plan |
| **Verifier** | relevant module-spec, quality.md, test expectations from MANIFEST.json | Needs to know what "correct" looks like for the module under test |
| **Security** | architecture.md, security-related module-specs, decisions.md | Needs system-wide view to assess attack surface and audit decisions |
| **Designer** | architecture.md (overview only), design/ directory contents | Needs to understand component structure for UI work |
| **Researcher** | domain/ directory, decisions.md | Needs domain context and historical decisions to inform research |
| **Investigator** | architecture.md, all module-specs, quality.md, PROGRESS.md | Needs comprehensive view to diagnose cross-cutting issues |
| **Optimizer** | architecture.md, relevant module-spec, quality.md | Needs to understand system structure and current quality to target improvements |
| **Strategist** | execution-plan.md, quality.md, MANIFEST.json, PROGRESS.md | Needs big-picture view of project health and trajectory |
| **Tester** | relevant module-spec, quality.md, MANIFEST.json acceptance criteria | Needs to know what to test and current quality baseline |

### How Partitioning Works

The orchestrating command (e.g., `/titan:06-build`) is responsible for loading the correct documentation partition before spawning an agent. The process:

```
1. Determine which agent is being spawned
2. Look up the agent in the partitioning table
3. Read the specified documents
4. Pass document contents as context to the agent
5. Do NOT pass documents not listed for that agent
```

**"Relevant module-spec" resolution:**

When the table says "relevant module-spec," the orchestrator determines which module is relevant by:
1. Reading the current feature from MANIFEST.json
2. Identifying which module(s) the feature touches (from the feature description and acceptance criteria)
3. Loading the module-spec(s) for those modules

If no module-spec exists yet (the module is being created for the first time), the orchestrator passes architecture.md instead and instructs the agent to create the module-spec as part of the implementation.

---

## Documentation Lifecycle

### Creation (Bootstrap)

During initialization (see `core/initializer-agent.md`), the following docs are created:

| Document | Content at Bootstrap |
|---|---|
| AGENTS.md | Populated with project info, initial constraints, doc map |
| INDEX.md | Lists all initial documents |
| architecture.md | Initial system design based on project vision |
| decisions.md | Empty (or first decision if tech stack was a choice) |
| execution-plan.md | Phase breakdown derived from MANIFEST.json |
| quality.md | All domains start at grade F or "Not Assessed" |
| module-specs/ | Empty directory (populated as modules are built) |
| domain/ | Populated with any domain reference material identified during analysis |

### Growth (During Development)

As the project grows, documentation grows with it:

- **New module-spec** created when a new module is first implemented
- **New domain doc** created when domain research surfaces reusable knowledge
- **New ADR** created when a significant design decision is made
- **execution-plan.md** updated at every checkpoint
- **quality.md** updated at every checkpoint (grades may change)
- **architecture.md** updated when system structure changes

### Maintenance (Staleness Prevention)

The staleness system (described above) ensures docs are maintained. Additionally:

- Agents that modify a module must check if the module-spec needs updating
- The `/titan:audit` command performs a comprehensive documentation health check
- quality.md serves as the dashboard for documentation health

### Retirement

Documents are never deleted, but they can be marked as:
- **Superseded** — replaced by a newer document (keep for historical reference)
- **Archived** — no longer relevant to active development (move to `.titan/docs/archive/`)

---

## Integration with Other Protocols

| Protocol | Integration Point |
|---|---|
| Initializer Agent | Creates the entire `.titan/docs/` scaffold at bootstrap |
| Session Orientation | Step 1 reads AGENTS.md and INDEX.md for orientation; staleness check during orientation |
| Session Checkpoint | Step 5 updates execution-plan.md and quality.md; checks for module-spec staleness |
| MANIFEST Protection | Feature descriptions in MANIFEST.json may reference module-specs; cross-references must be maintained |
| Audit Command | Triggers comprehensive staleness scan across all documentation |

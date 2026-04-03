---
name: titan:06-plan
description: Create a detailed execution plan for the current phase with tasks, waves, acceptance criteria, and boundaries.
---

# /titan:06-plan — Phase Execution Planning

> Create the execution blueprint for the current phase. This command analyzes the codebase,
> maps acceptance criteria to concrete tasks, organizes work into parallel waves, and produces
> a PLAN.md that the build step will execute literally.

## Prerequisites

Before running, verify ALL of the following exist. If any are missing, STOP and tell the user which prerequisite is unmet and which command to run.

- `.titan/STATE.md` exists (created by `/titan:01-init`)
- `.titan/ROADMAP.md` exists with at least one phase defined (created by `/titan:02-vision`)
- `.titan/REQUIREMENTS.md` exists with BDD acceptance criteria (created by `/titan:02-vision`)
- `.titan/ARCHITECTURE.md` exists (created by `/titan:02-vision`)
- `.titan/config.yaml` exists (created by `/titan:01-init`)
- STATE.md shows current step is `plan` or current phase status is `pending`

If STATE.md shows step is `build` or `verify`, warn the user: "Phase NN already has a plan. Run `/titan:07-build` to execute it, or confirm you want to re-plan."

---

## Process

### Step 1 — Display Banner and Orientation

Print:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — PLAN                                            ║
╚══════════════════════════════════════════════════════════════╝
Phase N of M ▓▓▓▓▓▓▓▓░░░░░░░░ XX%
```

Read STATE.md and ROADMAP.md. Identify the current phase:
- Phase number and name
- Phase goal (from ROADMAP.md)
- Phase scope (which requirements/ACs belong to this phase)

Print a brief orientation:
```
◆ Current Phase: Phase NN — [Phase Name]
◆ Goal: [One-line goal from ROADMAP.md]
◆ Acceptance Criteria: [count] criteria mapped to this phase
◆ Prior Exploration: [Yes/No — whether EXPLORATION.md exists for this phase]
```

### Step 2 — Determine the Phase Directory

The phase directory is: `.titan/phases/NN-phase-name/` (where NN is zero-padded phase number, phase-name is kebab-case).

Create this directory if it does not exist.

### Step 3 — Gather Context

Read the following files (in this order, stop reading a file if it exceeds 300 lines and note that sharding may be needed):

1. `.titan/REQUIREMENTS.md` — Extract ONLY the acceptance criteria mapped to this phase
2. `.titan/ARCHITECTURE.md` — Extract patterns, components, and interfaces relevant to this phase
3. `.titan/KNOWLEDGE.md` — Extract any existing project knowledge that applies
4. `.titan/DECISIONS.md` — Extract any prior decisions that constrain this phase
5. Phase-specific EXPLORATION.md (`.titan/phases/NN-phase-name/EXPLORATION.md`) — if it exists, incorporate findings
6. `.titan/config.yaml` — Load domain plugin name for domain-specific planning

### Step 3b — Review Background Captures (Cannibalized from GSD-2)

If `.titan/CAPTURES.md` exists and has entries:

1. Read all unreviewed captures
2. For each capture, assess relevance to the phase being planned:
   - **Relevant**: incorporate into the plan (add as a task, constraint, or risk)
   - **Not relevant**: skip (will be reviewed again at next planning phase)
   - **Stale**: mark as reviewed in CAPTURES.md
3. If any captures are relevant, note them in the plan's Context section
4. Print:
   ```
   ◆ Background Captures: [N] reviewed, [X] relevant to this phase
   ```

### Step 4 — Spawn titan-researcher Agent (Codebase Analysis)

Launch a subagent with the following brief:

```
AGENT: titan-researcher
TASK: Analyze the current codebase to inform planning for Phase NN — [Phase Name].

PHASE GOAL: [goal from ROADMAP.md]

ACCEPTANCE CRITERIA FOR THIS PHASE:
[list all ACs from REQUIREMENTS.md mapped to this phase]

INSTRUCTIONS:
1. Scan the project file tree. Identify all source files, test files, config files, and documentation.
2. For each acceptance criterion, identify:
   - Which existing files will need modification
   - Which new files will need creation
   - What existing patterns/conventions must be followed
   - What dependencies or imports are relevant
3. Identify architectural boundaries — files and modules that MUST NOT be modified by this phase.
4. Identify integration points — where new code connects to existing code.
5. Flag any risks: missing dependencies, unclear patterns, potential conflicts.
6. If a domain plugin is configured, apply domain-specific focus areas.

OUTPUT FORMAT:
Return a structured research report with these sections:
- FILE MAP: files to create, files to modify, files to read-only-reference
- PATTERNS: conventions discovered (naming, structure, error handling, testing)
- BOUNDARIES: files/modules that must not change
- INTEGRATION POINTS: where new code connects to existing
- RISKS: anything that could block or complicate execution
- DOMAIN NOTES: domain-plugin-specific observations (if applicable)
```

Collect the researcher's output. If the researcher reports critical risks or blockers, present them to the user immediately and ask whether to proceed or address the risks first.

### Step 5 — Construct the Task List

For each acceptance criterion mapped to this phase, create one or more tasks. Each task MUST have ALL of the following fields:

```markdown
### Task T[number]: [Short descriptive title]

- **AC**: [Which acceptance criterion this satisfies — reference by ID]
- **Mode**: [agent | in-session]
  - `agent` = Can be delegated to titan-executor (self-contained, file-scoped)
  - `in-session` = Must run in orchestrator session (integration, cross-cutting, safety-critical)
- **Files to Modify**: [explicit list of file paths]
- **Files to Create**: [explicit list of file paths, if any]
- **Files to Read** (reference only): [files the executor needs to read but not modify]
- **Action**: [Precise description of what to implement. Be specific enough that an executor with no prior context can do this.]
- **Verification Steps**:
  1. [Concrete check — e.g., "Run `npm test` and confirm all tests pass"]
  2. [Concrete check — e.g., "Verify file X exports function Y with correct signature"]
  3. [Concrete check — e.g., "Confirm no lint errors in modified files"]
- **Done Criteria**: [One sentence — the minimum bar for this task to be considered complete]
- **Dependencies**: [List of task IDs this depends on, or "none"]
```

Rules for task construction:
- Every AC MUST map to at least one task. No orphan ACs.
- Every task MUST have at least one verification step. No unverifiable tasks.
- Prefer `agent` mode unless the task requires cross-file integration, modifies safety-critical paths, or requires domain-specific processing (DSP) expertise that needs orchestrator context.
- Task descriptions must be detailed enough for a fresh-context executor agent to implement without asking questions.
- If a single AC requires multiple distinct code changes in different areas, split it into multiple tasks.

### Step 6 — Organize Tasks into Waves

Group tasks into execution waves based on dependencies:

```markdown
## Execution Strategy

### Wave 1 — Foundation (parallel)
Tasks with NO dependencies. These run as parallel titan-executor agents.
- Task T1: [title]
- Task T2: [title]

### Wave 2 — Integration (parallel where possible)
Tasks that depend on Wave 1 outputs. Parallel within the wave where deps allow.
- Task T3: [title] (depends on T1)
- Task T4: [title] (depends on T1, T2)

### Wave 3 — Polish & Integration (in-session)
Tasks requiring orchestrator context, cross-cutting concerns, or manual integration.
- Task T5: [title] (in-session, depends on T3, T4)
```

Rules for wave organization:
- Wave dependencies MUST be acyclic (no circular dependencies).
- Within a wave, tasks with no inter-dependencies run in parallel.
- In-session tasks go in the latest possible wave (defer to after agent work).
- Maximum 3 waves. If more are needed, the phase is too large — split it.

### Step 7 — Define Boundaries

Explicitly list what MUST NOT be modified during this phase:

```markdown
## Boundaries — DO NOT MODIFY

These files and directories are OUT OF SCOPE for this phase. Any executor that modifies
these files is in violation and the task must be rejected.

- [file/directory path] — [reason it's off-limits]
- [file/directory path] — [reason it's off-limits]
```

### Step 8 — Classify Checkpoints

Every point where the plan pauses for verification or user input gets a classification:

```markdown
## Checkpoints

| # | After | Type | Description |
|---|-------|------|-------------|
| 1 | Wave 1 complete | human-verify | Review Wave 1 outputs before proceeding |
| 2 | Task T4 | decision | Choose between approach A or B for [topic] |
| 3 | Before ship | human-action | User must configure API keys in .env |
```

Checkpoint types:
- `human-verify` (~90% of checkpoints): User confirms outputs look correct. Default after each wave.
- `decision` (~9%): User must choose between options. Only when the plan genuinely cannot predict the right choice.
- `human-action` (~1%): User must do something the AI cannot (configure secrets, approve external access, etc.).

### Step 9 — Risk Assessment

```markdown
## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [description] | Low/Medium/High | Low/Medium/High | [concrete mitigation step] |
```

Minimum 2 risks. Consider: scope creep, dependency issues, integration complexity, performance concerns, domain-specific risks.

### Step 10 — Work Unit Sizing Validation

Calculate the estimated scope:
- Count total tasks
- Estimate context consumption (each agent task ~10-15% of context, each in-session task ~15-25%)
- Sum to get total estimated context usage for the build phase

If estimated total exceeds 50% context OR task count exceeds 3:
- SPLIT the phase into sub-phases (e.g., Phase 3 becomes Phase 3.1 and Phase 3.2)
- Present the split to the user for approval
- Update ROADMAP.md with the sub-phases
- Re-plan for just the first sub-phase

### Step 11 — Validation Checklist

Before presenting to the user, run this checklist internally. ALL must pass:

```
☐ Every acceptance criterion has at least one task
☐ Every task has at least one verification step
☐ Every task has explicit files to modify/create
☐ Boundaries are explicitly defined
☐ Wave dependencies are acyclic (no circular references)
☐ No wave has more than 4 parallel agent tasks (to avoid overwhelming the system)
☐ Total estimated scope fits within 50% context budget
☐ Total tasks ≤ 3 (or phase has been split)
☐ In-session tasks are in the latest possible wave
☐ All task descriptions are detailed enough for a fresh-context executor
```

If any check fails, fix the plan before presenting it. Do NOT present a plan that fails validation.

### Step 12 — Write PLAN.md

Write the complete plan to `.titan/phases/NN-phase-name/PLAN.md` with this structure:

```markdown
---
phase: NN
name: [Phase Name]
goal: [One-line goal]
branch: titan/phase-NN-phase-name
status: draft
created: [ISO timestamp]
estimated_tasks: [count]
estimated_waves: [count]
---

# Phase NN — [Phase Name] — Execution Plan

## Goal
[1-2 sentence goal statement]

## Context
[Key findings from researcher agent and exploration, if applicable. 3-5 bullet points max.]

## Acceptance Criteria (This Phase)
[List each AC with its ID, copied from REQUIREMENTS.md]

## Tasks
[All tasks from Step 5, in order]

## Execution Strategy
[Wave structure from Step 6]

## Boundaries — DO NOT MODIFY
[From Step 7]

## Checkpoints
[From Step 8]

## Risk Assessment
[From Step 9]

## Validation
- [x] Every AC has at least one task
- [x] Every task has verification steps
- [x] Boundaries are explicit
- [x] Wave dependencies are acyclic
- [x] Total scope fits context budget
```

### Step 13 — Present Plan and Request Approval

Display a summary to the user.

Print (as markdown, NOT in a code block):

---

## ⚡ TITAN — PLAN READY FOR REVIEW

**Phase NN — [Phase Name]**

| Detail | Value |
|--------|-------|
| **Goal** | [goal] |
| **Tasks** | [count] ([agent count] agent, [in-session count] in-session) |
| **Waves** | [count] |
| **ACs Covered** | [count] |
| **Risks** | [count] identified |
| **Boundaries** | [count] files/dirs protected |

| Wave | Tasks |
|------|-------|
| Wave 1 | [task titles, comma-separated] |
| Wave 2 | [task titles, comma-separated] |
| Wave 3 | [task titles, comma-separated] |

✓ All validation checks passed.

> Review `.titan/phases/NN-phase-name/PLAN.md`

**Options:** `[approve]` Accept → `[modify]` Request changes → `[re-plan]` Discard → `[split]` Break into sub-phases

---

Wait for the user's response. Do NOT proceed to build without explicit approval.

### Step 14 — Update State

After approval, update STATE.md:

```markdown
## Current Position
- Phase: NN
- Step: build (ready)
- Status: active
- Last Action: Plan approved for Phase NN — [Phase Name]
- Updated: [ISO timestamp]
```

Set the PLAN.md frontmatter `status` from `draft` to `approved`.

---

## Outputs

| Artifact | Location | Description |
|----------|----------|-------------|
| PLAN.md | `.titan/phases/NN-phase-name/PLAN.md` | Complete execution plan |
| STATE.md | `.titan/STATE.md` | Updated with current position |
| ROADMAP.md | `.titan/ROADMAP.md` | Updated if phase was split |

---

## State Updates

- STATE.md `Phase` set to current phase number
- STATE.md `Step` set to `build (ready)`
- STATE.md `Status` set to `active`
- STATE.md `Last Action` set to plan approval description
- STATE.md `Next Action` set to `Run /titan:07-build to execute Phase NN`

---

## Error Handling

| Situation | Response |
|-----------|----------|
| ROADMAP.md has no pending phases | "All phases are complete. Run `/titan:09-ship` to release, or add new phases to ROADMAP.md." |
| REQUIREMENTS.md has no ACs for this phase | "No acceptance criteria mapped to Phase NN. Either update REQUIREMENTS.md or re-run `/titan:02-vision` to add requirements." |
| Researcher reports critical blockers | Present blockers to user. Offer: fix blockers first, plan around them, or skip phase. |
| Estimated scope exceeds 50% context | Auto-split into sub-phases. Present split for approval. |
| User rejects plan | Ask what to change. Apply modifications. Re-validate. Re-present. |
| EXPLORATION.md not found for phase | Proceed without exploration context. Note in plan: "No prior exploration. Consider running `/titan:04-explore` if unknowns exist." |
| Phase directory already has PLAN.md | Ask: "Phase NN already has a plan. Overwrite? [yes/no]" |

---

## What's Next

After the plan is approved, display (as markdown, NOT in a code block):

> ⟳ **Clear context before building.** A clean context window lets the build orchestrator work at full capacity. Your plan is saved in PLAN.md.

---

### ★ Recommended

> Run `/titan:07-build` to execute **Phase NN**. [X] tasks across [Y] waves are ready to go.

### Other options

| Command | Action |
|---------|--------|
| `/titan:04-explore` | Research unknowns before building (if the plan revealed gaps) |
| `/titan:05-design` | Design UI screens referenced in the plan (if not done yet) |
| `/titan:audit` | Run a security audit before building security-sensitive features |
| `/titan:progress` | See full project dashboard and current position |

---

## Anti-Rationalization Guard

During planning, you will be tempted to take shortcuts. Here are common rationalizations and why they are WRONG:

| Rationalization | Why It's Wrong | What To Do Instead |
|----------------|----------------|-------------------|
| "This phase is simple, I don't need to spawn the researcher" | The researcher finds patterns and conventions you'd miss. Skipping it causes executor agents to write inconsistent code. | Spawn the researcher. Always. |
| "I know what files need to change, skip the file mapping" | Incomplete file lists cause boundary violations and missed dependencies during build. | Map every file. The researcher does this in seconds. |
| "This task is self-explanatory, I don't need detailed action descriptions" | The executor gets a fresh context with zero prior knowledge. "Self-explanatory" to you is "ambiguous" to it. | Write action descriptions as if explaining to a new hire on day one. |
| "Verification steps are obvious, I'll keep them brief" | Vague verification steps like "verify it works" are unverifiable. The executor needs concrete commands. | Write concrete commands: `npm test`, `curl localhost:3000/api/health`, `grep -r 'TODO' src/`. |
| "I only need one wave, parallel execution is overkill" | Single-wave sequential execution wastes time and context. Independent tasks should run in parallel. | Identify true dependencies. Independent tasks go in the same wave. |
| "Boundaries aren't important for this small phase" | Small phases with no boundaries cause the most accidental side effects — there's nothing to stop the blast radius. | Define boundaries. Even one protected file prevents disasters. |
| "3 tasks is too constraining, this phase needs 6" | Large plans have exponentially more failure modes. Two 3-task phases execute cleaner than one 6-task phase. | Split the phase. TITAN will help you. |

## Output Validation (Self-Test)

Before presenting the plan for approval, verify that THIS COMMAND produced valid output. ALL must pass:

```
☐ PLAN.md exists at .titan/phases/NN-phase-name/PLAN.md
☐ PLAN.md has correct frontmatter (phase, name, goal, branch, status: draft)
☐ Every AC mapped to this phase has at least one task
☐ Every task has: AC reference, Mode, Files to Modify/Create, Action, Verification Steps, Done Criteria, Dependencies
☐ No task has empty or placeholder verification steps
☐ Wave dependencies are acyclic (no circular references)
☐ No wave has more than 4 parallel agent tasks
☐ Total tasks ≤ max_tasks_per_plan from config.yaml
☐ Boundaries section lists at least one protected path
☐ Risk assessment has at least 2 risks
☐ Phase directory .titan/phases/NN-phase-name/ exists
```

If ANY validation check fails, fix the plan before presenting it. Do NOT ask for approval on an invalid plan.

---

## Tips

- Run `/titan:04-explore` before `/titan:06-plan` if the phase involves unfamiliar technologies or novel problems.
- If you find yourself wanting more than 3 tasks, the phase is probably too big. Let TITAN split it.
- Boundary definitions save enormous debugging time. Be generous with what you protect.
- The researcher agent's output is your best friend — it finds patterns and conventions you'd otherwise miss.
- If the plan feels too simple, that's good. Simple plans execute cleanly. Complex plans breed bugs.

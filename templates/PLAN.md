---
# ⚡ TITAN Phase Plan
phase: "{{PHASE_NUMBER}}"
name: "{{PHASE_NAME}}"
goal: "{{PHASE_GOAL}}"
status: "planned"
created: "{{TIMESTAMP}}"
git_branch: "titan/phase-{{PHASE_NUMBER}}-{{PHASE_SLUG}}"
context_bracket: "green"
estimated_tasks: 0
completed_tasks: 0
profile: "balanced"
---

# ⚡ TITAN — Phase {{PHASE_NUMBER}}: {{PHASE_NAME}}

---

## Goal

> {{PHASE_GOAL}}
>
> **Success looks like:** {{SUCCESS_CRITERIA}}

---

## Context

_Context gathered during exploration. Remove this section if no exploration was done._

### From Exploration
- **Relevant files:** _list files that will be touched or referenced_
- **Existing patterns:** _patterns already in use that should be followed_
- **Dependencies:** _external or internal dependencies relevant to this phase_
- **Risks identified:** _anything that might complicate execution_

### Prerequisites
- [ ] Previous phase completed and reconciled
- [ ] Branch created from `main`
- [ ] All blockers from STATE.md resolved or accepted

---

## Acceptance Criteria

_From REQUIREMENTS.md — these are the BDD criteria that define "done" for this phase._

```gherkin
Given {{PRECONDITION}}
When  {{ACTION}}
Then  {{EXPECTED_OUTCOME}}
```

```gherkin
Given {{PRECONDITION_2}}
When  {{ACTION_2}}
Then  {{EXPECTED_OUTCOME_2}}
```

> Add all acceptance criteria here. Every criterion must be testable.
> A phase passes ONLY when ALL criteria are verified.

---

## Tasks

| ID | Description | Mode | Files | Action | Verify | Done | Depends On |
|----|-------------|------|-------|--------|--------|------|------------|
| T1 | {{TASK_1}} | agent | `file1.ts` | create | test passes | ○ | — |
| T2 | {{TASK_2}} | agent | `file2.ts` | modify | lint clean | ○ | — |
| T3 | {{TASK_3}} | in-session | `file3.ts`, `file4.ts` | refactor | integration test | ○ | T1, T2 |

**Mode Legend:**
- `agent` — Can be executed by a spawned agent (isolated, well-bounded)
- `in-session` — Must be executed in the current session (cross-cutting, risky, or complex)

**Action Legend:**
- `create` — New file(s) from scratch
- `modify` — Change existing file(s)
- `refactor` — Restructure without changing behavior
- `delete` — Remove file(s)
- `configure` — Update configuration only
- `test` — Write or update tests only

**Done Legend:**
- ○ Not started
- ◐ In progress
- ✓ Complete
- ✗ Failed (needs rework)
- ⊘ Skipped (with documented reason)

---

## Boundaries

**DO NOT MODIFY these files during this phase:**

- `{{BOUNDARY_FILE_1}}`
- `{{BOUNDARY_FILE_2}}`
- `.titan/STATE.md` (managed by TITAN only)
- `.titan/config.yaml` (unless this phase explicitly changes configuration)

> Boundaries prevent scope creep. If you discover a needed change outside
> boundaries, add it to Deferred Items in STATE.md for a future phase.

---

## Execution Strategy

### Wave 1 — Parallel (Independent Tasks)
_Tasks with no dependencies — can be executed simultaneously by agents._

| Task | Assignee | Status |
|------|----------|--------|
| T1 | agent | ○ |
| T2 | agent | ○ |

### Wave 2 — Dependent Tasks
_Tasks that depend on Wave 1 completion._

| Task | Depends On | Assignee | Status |
|------|-----------|----------|--------|
| T3 | T1, T2 | in-session | ○ |

### Wave 3 — In-Session Integration
_Tasks requiring full context — executed in the main session after agents complete._

| Task | Reason for In-Session | Status |
|------|----------------------|--------|
| T3 | Cross-module integration | ○ |

---

## Checkpoint Classification

Checkpoints pause execution for human input. Classify each checkpoint:

| Checkpoint | Type | Description | When |
|------------|------|-------------|------|
| — | — | — | _No checkpoints defined yet_ |

**Types:**
- `human-verify` — Human must confirm output is correct (visual review, business logic)
- `decision` — Human must choose between options (architecture, tool selection)
- `human-action` — Human must perform an action (deploy, configure external service, credentials)

> In autopilot mode, only checkpoints pause execution. All other tasks run automatically.

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {{RISK_1}} | medium | high | {{MITIGATION_1}} |
| {{RISK_2}} | low | medium | {{MITIGATION_2}} |

**Likelihood:** `low` | `medium` | `high`
**Impact:** `low` | `medium` | `high` | `critical`

> If a risk materializes during execution, add it to Blockers in STATE.md
> and pause for reassessment.

---

## Completion Checklist

Before marking this phase complete:

- [ ] All tasks marked ✓ (done) or ⊘ (skipped with reason)
- [ ] All acceptance criteria verified
- [ ] All quality gates passed (domain-specific checks)
- [ ] Atomic commits created (one per task)
- [ ] No lint errors or test failures
- [ ] KNOWLEDGE.md updated with learnings
- [ ] DECISIONS.md updated with any decisions made
- [ ] STATE.md reconciled with actual state
- [ ] Branch ready for merge/PR

---

_Plan created: {{TIMESTAMP}}_
_TITAN v1.0_

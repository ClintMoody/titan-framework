# ⚡ TITAN Framework — Project Rules for Claude Code

> **TITAN v1.0** — Meta-prompting framework for AI-assisted software development.
> These rules are loaded automatically. Do not remove or rename this file.

---

## The Golden Path

TITAN follows a strict workflow order. Every phase flows through this pipeline:

```
EXPLORE → PLAN → EXECUTE → VERIFY → RECONCILE
```

1. **Explore** — Understand the codebase, gather context, identify patterns
2. **Plan** — Decompose into bounded tasks with acceptance criteria
3. **Execute** — Implement one task at a time with atomic commits
4. **Verify** — Run quality gates, check acceptance criteria (BDD)
5. **Reconcile** — Sync STATE.md with reality, resolve deviations

Never skip steps. Never jump ahead. If in doubt, reconcile first.

---

## Git Conventions

### Atomic Commits
- **One task = one commit.** Never bundle multiple tasks into a single commit.
- Every commit must leave the project in a buildable, testable state.
- If a task is too large for one commit, the task is too large — split it.

### Branch Strategy
- Each phase gets its own branch: `titan/phase-{NN}-{name}`
- Branch from `main` (or the configured base branch)
- Merge via pull request after verification passes

### Commit Format
```
titan(phase-{NN}): {imperative description}
```
Examples:
- `titan(phase-01): add user authentication module`
- `titan(phase-03): fix rate limiter edge case for burst traffic`

### Rules
- **No force-push.** Ever. History is sacred.
- **No `--no-verify`.** Pre-commit hooks exist for a reason.
- **No empty commits.** Every commit must contain meaningful changes.
- **No merge commits in feature branches.** Rebase onto main.

---

## Code Conventions

<!-- TITAN:INIT populates these sections based on detected stack -->

### Language
<!-- {{LANGUAGE_CONVENTIONS}} -->
- Follow the language's official style guide
- Use consistent formatting (prefer automated formatters)
- Prefer explicit over implicit

### Framework
<!-- {{FRAMEWORK_CONVENTIONS}} -->
- Follow framework idioms and best practices
- Use framework-provided utilities over custom implementations
- Keep framework version pinned and documented

### Naming
<!-- {{NAMING_CONVENTIONS}} -->
- Use descriptive, intention-revealing names
- Avoid abbreviations unless universally understood
- Be consistent with casing conventions (camelCase, snake_case, etc.)

### File Organization
<!-- {{FILE_ORG_CONVENTIONS}} -->
- Group by feature/domain, not by file type
- Keep related files close together
- Limit file length — if a file exceeds 300 lines, consider splitting

### Testing
<!-- {{TESTING_CONVENTIONS}} -->
- Every feature needs tests before the phase is verified
- Test behavior, not implementation details
- Use descriptive test names that read as specifications
- Acceptance criteria use BDD format: Given / When / Then

### Linting & Formatting
<!-- {{LINTING_CONVENTIONS}} -->
- Run linter before every commit
- Zero warnings policy — treat warnings as errors
- Autoformat on save when possible

---

## Boundaries

### DO NOT
- **Do not manually edit `.titan/STATE.md`** — Only TITAN commands update state
- **Do not skip phases** — The Golden Path exists for a reason
- **Do not modify files outside the current task's boundary** — Each task lists its allowed files
- **Do not ignore failing tests** — Fix them or document why they're expected to fail
- **Do not create "temporary" workarounds** — If it ships, it's permanent
- **Do not exceed context brackets** — When context is orange/red, save state and start fresh

### DO
- **Follow the plan** — Execute tasks in the specified order
- **Respect file boundaries** — Only touch files listed in the task
- **Write acceptance criteria first** — Know what "done" looks like before starting
- **Commit atomically** — One task, one commit, one purpose
- **Reconcile when uncertain** — If state feels off, run reconciliation
- **Document decisions** — Add to DECISIONS.md when making non-obvious choices

---

## Domain-Specific Rules

<!-- TITAN:DOMAIN loads rules from the active domain plugin -->
<!-- {{DOMAIN_RULES}} -->

The active domain plugin adds additional quality checks, patterns, and anti-patterns.
These are enforced during verification and reconciliation.

See `.titan/config.yaml` for the active domain configuration.

---

## Work Unit Sizing

Tasks should be **small enough to hold in context, large enough to be meaningful**.

Guidelines:
- A task should touch **1-5 files** (if more, split it)
- A task should take **5-30 minutes** of AI execution time
- A task should have **clear, testable acceptance criteria**
- A task should produce **one atomic commit**

If a task feels too big, use `/titan:05-plan` to decompose further.

---

## BDD Acceptance Criteria Format

All acceptance criteria use Behavior-Driven Development format:

```gherkin
Given [initial context / precondition]
When  [action or event occurs]
Then  [expected outcome / observable result]
```

Example:
```gherkin
Given a user is logged in with valid credentials
When  they request their profile data via GET /api/profile
Then  the response returns 200 with their profile JSON
And   sensitive fields (password, SSN) are excluded
```

---

## Context Awareness

Monitor context usage throughout the session:

| Bracket | Range   | Action                                    |
|---------|---------|-------------------------------------------|
| ◆ Green | 0-50%   | Full capacity — plan and execute freely    |
| ⚠ Yellow| 50-70%  | Simplify — fewer tasks per plan            |
| ⚠⚠ Orange| 70-85% | Minimal — one task at a time, save often   |
| ⚠⚠⚠ Red | 85-100% | Critical — save state, start fresh session |

When approaching orange, proactively save state to STATE.md and suggest a fresh session.

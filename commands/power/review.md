---
name: titan:review
description: On-demand adversarial code review — targeted at specific files or a diff
---

# /titan:review — Adversarial Code Review

> Use anytime you want a quality review of specific code — not just during `/titan:07-verify`. Great for reviewing a PR, a specific file, or recent changes before committing.

## Prerequisites

- A codebase with code to review
- `.titan/` directory recommended but not required (works standalone)

## Process

### Step 1 — Define Review Scope

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — CODE REVIEW                                      ║
╚══════════════════════════════════════════════════════════════╝
```

Ask: **"What should I review?"**

Determine scope from user input:
- **Specific files:** "Review src/auth/login.ts"
- **Recent changes:** "Review my uncommitted changes" → use `git diff`
- **Branch diff:** "Review this branch vs main" → use `git diff main...HEAD`
- **Last N commits:** "Review the last 3 commits" → use `git log` + `git diff`
- **Everything:** "Full review" → review all source files (may need to shard for large codebases)

### Step 2 — Load Context

Read the files/diff to review. Also read:
- `.titan/config.yaml` (if exists) — to load domain plugin
- `CLAUDE.md` (if exists) — to understand project conventions
- `.titan/ARCHITECTURE.md` (if exists) — to understand intended architecture

### Step 3 — Spawn Verifier Agent

Spawn `titan-verifier` agent with:
- The code to review
- Project conventions and architecture context
- Domain plugin checks (if configured)
- Instruction: "This is an on-demand review, not a phase verification. Focus on the code provided."

If the codebase is small enough, review in-session instead of spawning an agent.

### Step 4 — Review Across 5 Dimensions

The review evaluates:

1. **Correctness** — Does the code do what it claims? Logic errors, off-by-one, null handling, edge cases.
2. **Security** — Injection vulnerabilities, authentication/authorization issues, data exposure, dependency risks.
3. **Architecture** — Does it follow project patterns? Appropriate abstractions? Clean boundaries?
4. **Code Quality** — Readability, naming, duplication, complexity, error handling.
5. **Domain-Specific** — Loaded from domain plugin (e.g., accessibility for web, real-time safety for audio).

**HALT CONDITION:** If zero issues found, re-review with fresh eyes. Real code always has at least one thing that could be improved.

### Step 5 — Present Findings

Format findings as:

```markdown
## Review: [scope description]

### Critical (must fix)
- **[file:line]** — [description of issue]
  Fix: [suggested fix]

### Important (should fix)
- **[file:line]** — [description of issue]
  Fix: [suggested fix]

### Minor (consider fixing)
- **[file:line]** — [description of issue]
  Fix: [suggested fix]

### Positive Notes
- [Things done well — always include at least one]

### Summary
[overall assessment — PASS | PASS-WITH-NOTES | NEEDS-WORK]
[X] critical, [Y] important, [Z] minor findings
```

### Step 6 — Offer to Fix

Ask: "Would you like me to fix any of these issues?"

If yes: apply fixes directly, one at a time, with atomic commits if in a git repo.

## Outputs

- Review findings displayed to user
- Optionally: code fixes applied

## State Updates

- STATE.md: Last Action updated (if .titan/ exists)

## Error Handling

- **Files not found:** List available files, ask user to clarify
- **Diff is empty:** Report "no changes to review" and suggest what to try
- **Too much code to review at once:** Split into focused reviews by module/feature

## What's Next

After the review is complete, display (as markdown, NOT in a code block):

---

### ★ Recommended

> **Address the findings.**
> [If fixes were applied: Run `/titan:test` to verify the fixes.]
> [If fixes were declined: Continue with your current workflow.]
> [If NEEDS-WORK: Fix the critical/important issues before proceeding.]

### Other options

| Command | Action |
|---------|--------|
| `/titan:test` | Generate or run tests to confirm fixes |
| `/titan:audit` | Full multi-dimensional audit (if review found security concerns) |
| `/titan:refactor` | Refactor if the review found structural issues |
| `/titan:06-build` | Continue building (if review passed) |
| `/titan:07-verify` | Proceed to verification (if review was the final check) |

---

## Tips

- Run `/titan:review` before committing significant changes — catch issues early.
- The "Positive Notes" section isn't filler — it reinforces good patterns.
- Don't ignore "minor" findings in aggregate — many small issues signal a trend.
- For the most thorough review, provide architectural context (ARCHITECTURE.md helps a lot).

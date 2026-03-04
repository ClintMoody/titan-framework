---
name: titan:experiment
description: Try multiple approaches in isolation — prototype, measure, compare, decide
---

# /titan:experiment — Isolated Prototyping and Comparison

> Use when `/titan:investigate` has identified candidate approaches and you want to test them hands-on before committing. Also useful anytime you're torn between 2-3 ways to implement something.

## Prerequisites

- `.titan/` directory exists (run `/titan:init` if not)
- Ideally, an INVESTIGATION.md with candidate approaches — but not required. You can experiment ad hoc.
- Git repository with clean working tree (uncommitted changes will be stashed)

## Process

### Step 1 — Define the Experiment

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — EXPERIMENT                                       ║
╚══════════════════════════════════════════════════════════════╝
```

Ask the user:
1. **What are we testing?** (the hypothesis or question)
2. **Which approaches?** (list 2-3 candidates — pull from INVESTIGATION.md if it exists)
3. **What does success look like?** (measurable criteria: performance, readability, correctness, bundle size, etc.)
4. **How will we measure?** (tests, benchmarks, manual review, etc.)

If an INVESTIGATION.md exists in `.titan/investigations/`, offer to import its top candidates automatically.

### Step 2 — Assign Experiment ID

```
NNN = next available number in .titan/experiments/
slug = kebab-case summary of hypothesis
directory = .titan/experiments/NNN-slug/
```

Create the directory. Write initial `EXPERIMENT.md` header:

```markdown
# Experiment NNN: [Title]

- **Hypothesis:** [What we're testing]
- **Approaches:** [List]
- **Success Criteria:** [Measurable]
- **Measurement:** [How]
- **Status:** IN PROGRESS
- **Started:** [ISO timestamp]
```

### Step 3 — Prototype Each Approach

For each candidate approach:

1. **Create isolation** — Create a git branch: `titan/experiment-NNN-approach-N`
2. **Build the minimum viable prototype** — Only enough code to test the hypothesis. No polish. No edge cases. Just prove the concept works or doesn't.
3. **Run measurements** — Execute whatever success criteria were defined (run tests, run benchmarks, inspect output, check bundle size, etc.)
4. **Record results** — Add to EXPERIMENT.md:

```markdown
## Approach N: [Name]

### Implementation
[Brief description of what was built, key files/lines]

### Results
| Criterion | Target | Actual | Pass? |
|-----------|--------|--------|-------|
| [criterion] | [target] | [actual] | ✓/✗ |

### Observations
- [What worked well]
- [What didn't]
- [Surprises]
```

5. **Switch back** to original branch before next approach

Repeat for each approach.

### Step 4 — Compare

Add a comparison matrix to EXPERIMENT.md:

```markdown
## Comparison

| Criterion | Approach 1 | Approach 2 | Approach 3 | Winner |
|-----------|-----------|-----------|-----------|--------|
| [criterion] | [result] | [result] | [result] | [N] |

**Overall Winner:** Approach N — [Name]
**Rationale:** [Why this one wins]
```

### Step 5 — Decide

Ask the user: "Based on these results, which approach should we go with?"

Options:
- **Keep winner** — Merge the winning branch into the working branch
- **Modify** — Take the best parts of multiple approaches (create a synthesis plan)
- **Discard all** — None of the approaches work; need to rethink (chain back to `/titan:investigate`)
- **Defer** — Save results but don't merge yet

### Step 6 — Finalize

1. If keeping: merge the winning branch, clean up experiment branches
2. Update EXPERIMENT.md with final decision and status
3. Update `.titan/KNOWLEDGE.md` with what was learned
4. Update `.titan/DECISIONS.md` if a significant decision was made
5. Update STATE.md

```markdown
- **Decision:** [Which approach and why]
- **Status:** COMPLETE
- **Completed:** [ISO timestamp]
```

## Outputs

- `.titan/experiments/NNN-slug/EXPERIMENT.md` — Full experiment record
- Git branches with prototypes (merged or deleted based on decision)
- Updates to KNOWLEDGE.md and DECISIONS.md

## State Updates

- STATE.md: Last Action updated to "Experiment NNN: [slug] — [result]"
- Knowledge Snapshots: Add key learning

## Error Handling

- **Git conflicts on merge:** Present to user, assist with resolution
- **Prototype fails to build:** Record as "FAILED — [reason]" in results, continue to next approach
- **All approaches fail:** Recommend `/titan:investigate` with refined understanding
- **User wants more approaches:** Add them — no limit beyond practical context constraints

## Tips

- Keep prototypes MINIMAL. The goal is to answer a question, not build a feature.
- Measure before you judge. Gut feelings about "which is cleaner" are less valuable than benchmarks.
- If two approaches are very close, pick the simpler one. Simplicity wins ties.
- Experiment records are valuable even when the project is done — they explain WHY certain approaches were chosen.

---
name: titan:refactor
description: Safe refactoring with test preservation — every change verified against tests
---

# /titan:refactor — Safe, Verified Refactoring

> Use when you need to restructure, rename, extract, or simplify code without changing behavior. TITAN ensures tests pass before AND after every change.

## Prerequisites

- Code to refactor
- Ideally: existing tests covering the affected code (TITAN will generate them if missing)
- `.titan/` directory recommended

## Process

### Step 1 — Define Refactoring

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — REFACTOR                                         ║
╚══════════════════════════════════════════════════════════════╝
```

Ask: **"What do you want to refactor and why?"**

Common refactoring types:
- **Rename** — Variable, function, class, file, module
- **Extract** — Pull code into a function, component, module, or class
- **Inline** — Collapse unnecessary abstraction
- **Move** — Relocate code to a better home
- **Simplify** — Reduce complexity, remove indirection
- **Restructure** — Reorganize file/folder structure
- **Decouple** — Remove tight coupling between components

### Step 2 — Safety Check: Tests Exist?

Read the affected code. Check if tests exist that cover this code.

**If tests exist:**
- Run the full test suite. Confirm all tests pass.
- Record baseline: "X tests passing before refactoring."
- Proceed to Step 3.

**If tests DON'T exist:**
- WARN the user: "No tests cover this code. Refactoring without tests is risky."
- Offer two options:
  1. **Generate tests first** (recommended) — spawn `titan-tester` to create tests for the current behavior, then proceed
  2. **Proceed without tests** (user accepts risk) — skip to Step 3 with extra manual verification

### Step 3 — Plan the Refactoring

Break the refactoring into the SMALLEST possible steps. Each step should:
- Make exactly one change
- Keep the code in a working state
- Be independently verifiable

Example plan for "Extract a component":
1. Create the new file
2. Copy the code to the new file
3. Add the export
4. Import from the new location in the original file
5. Remove the old code from the original file
6. Update any other imports

Present the plan to the user for approval.

### Step 4 — Execute Step by Step

For each refactoring step:

1. **Make the change**
2. **Run tests immediately**
   - If tests PASS → commit: `titan(refactor): [description]`
   - If tests FAIL → **STOP immediately**. Revert the change. Analyze why. Adjust the plan.
3. **Move to the next step**

Display progress:
```
Refactoring: Extract AuthService
  ✓ Step 1/6: Create auth-service.ts
  ✓ Step 2/6: Copy authentication logic
  ✓ Step 3/6: Export AuthService class
  ◆ Step 4/6: Update imports in login.ts
  ○ Step 5/6: Remove old code from app.ts
  ○ Step 6/6: Update remaining imports
```

### Step 5 — Final Verification

After all steps complete:

1. Run the FULL test suite (not just affected tests)
2. Compare against baseline: same number of tests passing? Any new failures?
3. Quick code review of the changes — does the refactored code meet the goal?
4. Report:

```
Refactoring Complete: [description]
  Steps: 6/6 complete
  Tests: XX passing (baseline: XX) ✓
  Files changed: N
  Lines: +XX / -YY (net: ±ZZ)
```

### Step 6 — Update Knowledge

If the refactoring revealed patterns or insights:
- Update `.titan/KNOWLEDGE.md` with what was learned
- If a significant structural decision was made, update `.titan/DECISIONS.md`

## Outputs

- Refactored code with atomic commits per step
- All tests passing
- Optionally: new tests generated for previously untested code

## State Updates

- STATE.md: Last Action updated

## Key Rules

1. **Tests MUST pass after every step.** No exceptions. If they break, revert and reassess.
2. **Smallest possible steps.** The risk of a refactoring is proportional to the size of each change.
3. **Never change behavior.** Refactoring changes structure, not functionality. If you need to change behavior, that's a feature or a bug fix, not a refactoring.
4. **Commit each step.** If something goes wrong later, you can revert to any intermediate state.

## Error Handling

- **Tests fail after a step:** Revert immediately. Analyze the failure. Adjust the plan. Try again.
- **Circular dependencies created:** Flag and resolve before proceeding
- **Too many affected files:** Break into multiple smaller refactoring sessions
- **No test framework:** Recommend one, offer to set up, then proceed

## Tips

- The best refactoring is the one you don't notice. Small, frequent refactorings beat large, scary ones.
- If you can't describe the refactoring goal in one sentence, you're doing too much at once. Split it.
- "Make the change easy, then make the easy change." — Kent Beck

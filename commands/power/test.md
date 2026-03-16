---
name: titan:test
description: Generate tests or run TDD workflows — behavior-focused, edge-case-aware
---

# /titan:test — Test Generation and TDD

> Use to generate comprehensive tests for existing code, or to work in TDD mode (write failing test → implement → refactor).

## Prerequisites

- Source code to test (for generation mode) or requirements to test against (for TDD mode)
- `.titan/` directory recommended but not required

## Process

### Step 1 — Choose Mode

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — TEST                                             ║
╚══════════════════════════════════════════════════════════════╝
```

Ask: **"What would you like to do?"**

1. **Generate tests** — Analyze existing code and create comprehensive tests
2. **TDD mode** — Write a failing test first, then implement to make it pass
3. **Edge case discovery** — Find untested edge cases in existing tests

### Step 2A — Generate Mode

If generating tests for existing code:

1. **Identify targets** — Ask which files/functions/modules to test. Read the source code.
2. **Detect test framework** — Check existing tests, package.json/requirements.txt/etc. for the framework in use (Jest, pytest, Go testing, etc.). If none, recommend one.
3. **Spawn titan-tester agent** with:
   - Source files to test
   - Existing test files (for style consistency)
   - Project conventions
   - Domain plugin
4. **Agent generates tests covering:**
   - **Happy path** — Normal expected inputs and outputs
   - **Edge cases** — Boundaries, empty inputs, maximum values, null/undefined
   - **Error cases** — Invalid inputs, network failures, permission errors
   - **Integration points** — How components interact (if applicable)
5. **Present tests** to user for review before writing to disk
6. **Run tests** to verify they pass (for existing code) or fail meaningfully (for TDD)

### Step 2B — TDD Mode

If working in TDD:

1. **Identify the requirement** — What behavior should we implement? (Pull from REQUIREMENTS.md if available)
2. **RED phase:**
   - Write a failing test that describes the desired behavior
   - Run the test — confirm it fails for the RIGHT reason
   - Commit: `titan(tdd): red — [test description]`
3. **GREEN phase:**
   - Write the MINIMUM code to make the test pass
   - Run the test — confirm it passes
   - Commit: `titan(tdd): green — [test description]`
4. **REFACTOR phase:**
   - Improve the code without changing behavior
   - Run all tests — confirm everything still passes
   - Commit: `titan(tdd): refactor — [description]`
5. **Repeat** for the next requirement

Context management: TDD plans target 40% context (from config.yaml `tdd.context_target`).

### Step 2C — Edge Case Discovery

If discovering edge cases:

1. Read existing tests and source code
2. Analyze for untested scenarios:
   - Boundary values (0, -1, MAX_INT, empty string, empty array)
   - Type coercion edge cases
   - Concurrent/async race conditions
   - Resource limits (out of memory, disk full, network timeout)
   - Unicode, special characters, very long strings
   - Null, undefined, NaN propagation
3. Present discovered edge cases with suggested test code
4. User selects which to add

### Step 3 — Write Tests

Write test files following project conventions:
- Same directory structure as source (or `__tests__/` or `tests/` depending on convention)
- Consistent naming: `[source].test.[ext]` or `test_[source].[ext]`
- Clear describe/it blocks with readable descriptions
- Tests should document behavior, not implementation details

### Step 4 — Verify

Run the full test suite. Report:
```
Tests: XX passed, YY failed, ZZ skipped
Coverage: ~NN% (estimated based on test analysis)
New tests added: NN
```

If any tests fail unexpectedly, investigate and fix.

## Outputs

- Test files written to appropriate locations
- Test execution results
- Coverage estimate

## State Updates

- STATE.md updated if within a phase

## Key Principles

1. **Test behavior, not implementation** — Test WHAT the code does, not HOW it does it
2. **One assertion per test** (ideal) — Each test should verify one thing
3. **Readable test names** — `it('should reject passwords shorter than 8 characters')` not `it('test1')`
4. **No test interdependence** — Tests must run independently in any order
5. **Mock at boundaries** — Mock external services, not internal implementation

## Anti-Rationalization Guard — The TDD Iron Law

When working in TDD mode (especially with `tdd.strict: true`), you WILL be tempted to skip steps. Every rationalization below has been observed in AI agents. They all lead to the same outcome: bugs in production that tests should have caught.

| Rationalization | Why It's Wrong | What To Do Instead |
|----------------|----------------|-------------------|
| "This is too simple to test" | Simple functions have the highest bug-to-complexity ratio. Off-by-one, null checks, empty inputs. 30 seconds to test. | Write the test. It's fast precisely BECAUSE it's simple. |
| "I'll write the tests after the implementation" | Tests written after implementation test what the code does, not what it should do. They encode bugs as features. | Delete the implementation. Write the failing test first. |
| "The function is a one-liner, testing it is pointless" | One-liners are called from many places. When they break, everything breaks. | One-line function = one-line test. No excuse. |
| "TDD will slow me down" | TDD front-loads debugging time. Without it, you debug in production. That's slower. | Trust the cycle. RED-GREEN-REFACTOR is faster over the full lifecycle. |
| "I need to prototype first, then add tests" | Prototypes without tests become production code. "I'll add tests later" is the biggest lie in software. | Prototype WITH tests. A failing test IS a prototype of the requirement. |
| "This is just configuration / boilerplate" | Config bugs are the hardest to debug because everyone assumes "config can't be wrong." | Test that config produces expected behavior. |
| "The types / compiler will catch errors" | Types catch type errors. They don't catch logic errors, edge cases, or integration failures. | Types are not tests. Write both. |
| "I can't test this because it has side effects" | Side effects are WHERE bugs live. If you can't test it, you can't verify it. | Refactor to make it testable. Inject dependencies. Mock boundaries. |
| "This test is flaky so I'll skip it" | Flaky tests indicate real concurrency or timing bugs. Skipping them hides the bug. | Fix the flakiness. Use deterministic inputs. Mock time. |
| "We're under time pressure, tests can wait" | Tests save more time than they cost. Every phase. Every time. The data is unambiguous. | Time pressure means you can afford FEWER bugs, not fewer tests. |
| "The existing code doesn't have tests" | That's a reason to ADD tests, not skip them. | Write tests for the code you're touching. Incremental coverage. |
| "I'll refactor later, this is just a first pass" | "Later" is another conversation with no context. Refactor now in the REFACTOR step. | Complete the RED-GREEN-REFACTOR cycle. That IS the first pass. |

## What's Next

After tests are generated and passing, display (as markdown, NOT in a code block):

---

### ★ Recommended

> **Continue with your current workflow.**
> [If mid-build: Continue `/titan:06-build` for Phase NN.]
> [If pre-verify: Run `/titan:07-verify` — your test coverage is stronger now.]
> [If standalone: Run `/titan:progress` to see your current position.]

### Other options

| Command | Action |
|---------|--------|
| `/titan:review` | Review the code alongside its new tests |
| `/titan:06-build` | Continue building the current phase |
| `/titan:07-verify` | Verify the current phase |
| `/titan:audit` | Run a full quality audit |

---

## Error Handling

- **No test framework installed:** Recommend one based on the language/framework, offer to install
- **Tests won't run:** Check configuration, report setup issues
- **Flaky tests:** Flag tests that pass/fail inconsistently, suggest fixes

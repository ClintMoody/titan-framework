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

## Error Handling

- **No test framework installed:** Recommend one based on the language/framework, offer to install
- **Tests won't run:** Check configuration, report setup issues
- **Flaky tests:** Flag tests that pass/fail inconsistently, suggest fixes

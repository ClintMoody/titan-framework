---
name: titan:enforce
description: Run the architectural enforcement suite manually
---

# /titan:enforce — Architectural Enforcement

> Use this command to validate that the codebase follows architectural rules, naming conventions, dependency constraints, and quality thresholds. Run it manually or integrate it into the build loop.

## Prerequisites

- A codebase to enforce rules against.
- `.titan/` directory recommended (enables rule loading and state tracking).

If `.titan/enforcement/architecture-rules.json` does not exist, offer to create it:
```
○ No enforcement rules found at .titan/enforcement/architecture-rules.json
  Would you like to generate a default rule set based on your project structure? (y/n)
```

## Process

### Step 1: Display Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — ARCHITECTURAL ENFORCEMENT                        ║
╚══════════════════════════════════════════════════════════════╝

  Validating architecture rules, boundaries, and conventions.
```

### Step 2: Load Enforcement Rules

Read `.titan/enforcement/architecture-rules.json`. Expected structure:

```json
{
  "version": "2.0",
  "rules": {
    "module_boundaries": {
      "enabled": true,
      "modules": {
        "ui": { "allowed_imports": ["shared", "utils"], "forbidden_imports": ["database", "server"] },
        "database": { "allowed_imports": ["shared"], "forbidden_imports": ["ui", "routes"] },
        "server": { "allowed_imports": ["database", "shared", "utils"], "forbidden_imports": ["ui"] }
      }
    },
    "dependency_direction": {
      "enabled": true,
      "layers": ["ui", "routes", "services", "database", "shared"],
      "direction": "top-down"
    },
    "naming_conventions": {
      "enabled": true,
      "rules": [
        { "pattern": "src/components/**/*.{ts,tsx}", "convention": "PascalCase" },
        { "pattern": "src/utils/**/*.ts", "convention": "camelCase" },
        { "pattern": "src/**/*.test.ts", "convention": "*.test.ts" }
      ]
    },
    "file_size_limits": {
      "enabled": true,
      "max_lines": 500,
      "exceptions": ["generated/**", "vendor/**"]
    },
    "test_coverage": {
      "enabled": true,
      "min_threshold": 70,
      "critical_paths_threshold": 90
    },
    "code_hygiene": {
      "enabled": true,
      "scan_patterns": ["TODO", "FIXME", "HACK", "XXX", "TEMP"]
    },
    "manifest_validation": {
      "enabled": true
    }
  }
}
```

If the file doesn't exist and the user agrees to generate defaults, analyze the project structure and create a sensible default rule set.

### Step 3: Run Module Boundary Validation

For each module defined in the rules:
1. Scan all source files in the module directory
2. Extract import/require statements
3. Check each import against the `allowed_imports` and `forbidden_imports` lists
4. Flag violations with file path, line number, and the offending import

```
◆ Module Boundary Check
  ✓ ui — 42 imports checked, 0 violations
  ✗ server — 38 imports checked, 2 violations
    → src/server/handler.ts:14 — imports from "ui/components" (forbidden)
    → src/server/middleware.ts:8 — imports from "ui/hooks" (forbidden)
```

### Step 4: Run Dependency Direction Check

Ensure layers only import from the same layer or lower layers:
1. Map each source file to its layer
2. For each import, determine the target layer
3. Flag upward imports (lower layer importing from higher layer)

```
◆ Dependency Direction Check
  ✓ All imports flow top-down — no violations.
```

Or:
```
◆ Dependency Direction Check
  ✗ 3 upward dependency violations found
    → src/database/cache.ts:5 — imports from "services" layer (database → services)
```

### Step 5: Run Naming Convention Check

For each naming rule:
1. Glob for matching files
2. Check that file/directory names match the expected convention
3. Flag violations with the expected vs actual name

```
◆ Naming Convention Check
  ✓ Components (PascalCase) — 24 files, 0 violations
  ✗ Utils (camelCase) — 12 files, 1 violation
    → src/utils/DataParser.ts — expected camelCase (should be dataParser.ts)
```

### Step 6: Run File Size Check

For each source file (excluding exceptions):
1. Count lines
2. Flag files exceeding `max_lines`

```
◆ File Size Check
  ✗ 2 files exceed 500 line limit
    → src/server/routes.ts — 847 lines (347 over limit)
    → src/utils/parser.ts — 612 lines (112 over limit)
```

### Step 7: Run Test Coverage Check

If coverage data is available (look for coverage reports in standard locations):
1. Parse coverage report
2. Compare against thresholds
3. Flag modules below threshold

If no coverage data:
```
○ No coverage data found. Run your test suite with coverage enabled first.
  Skipping coverage check.
```

### Step 8: Run Code Hygiene Scan

Scan all source files for TODO/FIXME/HACK/XXX/TEMP markers:

```
◆ Code Hygiene Scan
  Found 14 markers across 8 files:
    TODO:  8 occurrences
    FIXME: 3 occurrences
    HACK:  2 occurrences
    XXX:   1 occurrence

  Highest density:
    → src/server/auth.ts — 4 markers (TODO:2, HACK:1, FIXME:1)
```

### Step 9: Run MANIFEST.json Schema Validation

If `.titan/MANIFEST.json` exists:
1. Validate JSON structure against expected schema
2. Check all required fields are present
3. Verify feature IDs are sequential and unique
4. Verify dependency references point to valid feature IDs
5. Verify status values are valid ("passing" or "failing")

```
◆ MANIFEST.json Validation
  ✓ Schema valid — 24 features, all fields present
  ✓ Feature IDs sequential and unique
  ✓ All dependency references valid
```

### Step 10: Display Results Summary

Print (as markdown, NOT in a code block):

---

## ⚡ TITAN — ENFORCEMENT RESULTS

| Check | Status | Violations | Details |
|-------|--------|-----------|---------|
| Module Boundaries | ✓ Pass | 0 | 80 imports checked |
| Dependency Direction | ✗ Fail | 3 | Upward dependencies found |
| Naming Conventions | ✗ Fail | 1 | 1 file misnamed |
| File Size Limits | ✗ Fail | 2 | 2 files over 500 lines |
| Test Coverage | ○ Skip | — | No coverage data |
| Code Hygiene | ⚠ Warn | 14 | 14 markers in 8 files |
| MANIFEST Validation | ✓ Pass | 0 | Schema valid |

**Total:** [X] violations, [Y] warnings

---

### Step 11: Offer Auto-Fixes

For violations that can be auto-fixed:

```
◆ Auto-fixable issues found:

  1. Rename src/utils/DataParser.ts → src/utils/dataParser.ts
     (update all import references)

  2. Remove unused import in src/server/handler.ts:14

Apply auto-fixes? (y/n/select)
```

If yes: apply fixes, run enforcement again to confirm, then commit:
```
titan(enforce): auto-fix naming conventions and unused imports
```

Teaching messages for each violation explain:
- **WHY** it's wrong (architectural reasoning)
- **HOW** to fix it (specific steps)
- **DOCS** reference (link to relevant rule or pattern)

---

### ★ Recommended

> [If violations found: "Fix the [X] violations — auto-fix what's possible, manually resolve the rest."]
> [If clean: "Architecture is clean. Continue development."]

### Other options

| Command | Action |
|---------|--------|
| `/titan:refactor` | Refactor files flagged for structural issues |
| `/titan:audit` | Run a full multi-dimensional audit |
| `/titan:07-verify` | Run verification suite |
| `/titan:06-build` | Continue building |

---

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| Enforcement results | Console output | Immediate feedback |
| architecture-rules.json | `.titan/enforcement/architecture-rules.json` | Rule definitions (if generated) |
| Auto-fix commit | Git history | Applied fixes (if accepted) |

## State Updates

- STATE.md Last Action updated
- KNOWLEDGE.md updated with any new architectural patterns discovered

## Error Handling

| Error | Resolution |
|-------|-----------|
| No rules file and user declines generation | Run with sensible defaults, don't persist rules |
| Source directory structure doesn't match rules | Suggest updating rules to match actual structure |
| Import parsing fails for language | Fall back to regex-based import scanning |
| Very large codebase (>10k files) | Shard enforcement by module, run in parallel |
| Auto-fix would break other imports | Show preview of all affected files before applying |

## Tips

- Run `/titan:enforce` before every commit to catch architectural drift early.
- The rules file is meant to evolve — start strict, relax where justified, and document exceptions.
- Module boundary violations are the most important check — they prevent spaghetti architecture.
- File size limits are a code smell detector, not a hard rule — large generated files are fine.
- Teaching error messages are intentional — they help you understand the architecture, not just fix the error.

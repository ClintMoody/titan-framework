# Architectural Enforcement Layer

**Upgrade 19 — Phase 6: Autonomous Loop Engine**

Deterministic rules the agent cannot bypass. While agents have judgment and flexibility in *how* they implement features, the enforcement layer defines hard boundaries that are checked automatically. No commit, no merge, no status change can violate these rules.

---

## Why Enforcement Exists

Agents are powerful but probabilistic. They may:
- Introduce circular dependencies while fixing a bug
- Exceed file size limits while adding features
- Skip formatting while rushing to pass E2E
- Leave TODO markers that indicate incomplete work
- Break module boundaries while implementing cross-cutting features

The enforcement layer makes these violations **impossible to commit**, not just discouraged.

---

## The 4 Enforcement Components

### Component 1: Git Pre-Commit Hooks

Pre-commit hooks run automatically on every `git commit`. If any check fails, the commit is rejected. The agent must fix the issue before proceeding.

**Installation:** `.git/hooks/pre-commit`

```bash
#!/bin/bash
# TITAN Pre-Commit Hook
# Runs all enforcement checks before allowing a commit

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "TITAN Pre-Commit Checks"
echo "======================="

# ─── Check 1: Formatting ─────────────────────────────────────────────────
echo -n "  Formatting... "
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# C/C++ formatting
CPP_FILES=$(echo "$STAGED_FILES" | grep -E '\.(cpp|h|hpp|c)$' || true)
if [ -n "$CPP_FILES" ]; then
  for f in $CPP_FILES; do
    if ! clang-format --dry-run --Werror "$f" 2>/dev/null; then
      echo "FAIL"
      echo "    $f is not formatted. Run: clang-format -i $f"
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

# JavaScript/TypeScript formatting
JS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(js|ts|jsx|tsx|json|css)$' || true)
if [ -n "$JS_FILES" ]; then
  if command -v prettier &>/dev/null; then
    for f in $JS_FILES; do
      if ! prettier --check "$f" 2>/dev/null; then
        echo "FAIL"
        echo "    $f is not formatted. Run: prettier --write $f"
        ERRORS=$((ERRORS + 1))
      fi
    done
  fi
fi

# Rust formatting
RS_FILES=$(echo "$STAGED_FILES" | grep -E '\.rs$' || true)
if [ -n "$RS_FILES" ]; then
  if command -v rustfmt &>/dev/null; then
    if ! cargo fmt --check 2>/dev/null; then
      echo "FAIL"
      echo "    Rust code not formatted. Run: cargo fmt"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

[ $ERRORS -eq 0 ] && echo "OK"

# ─── Check 2: Lint ───────────────────────────────────────────────────────
echo -n "  Linting... "
LINT_ERRORS=0

if [ -n "$CPP_FILES" ] && command -v clang-tidy &>/dev/null; then
  for f in $CPP_FILES; do
    if ! clang-tidy "$f" -- -std=c++17 2>/dev/null | grep -q "0 warnings"; then
      LINT_ERRORS=$((LINT_ERRORS + 1))
    fi
  done
fi

if [ -n "$JS_FILES" ] && command -v eslint &>/dev/null; then
  for f in $JS_FILES; do
    if ! eslint "$f" 2>/dev/null; then
      LINT_ERRORS=$((LINT_ERRORS + 1))
    fi
  done
fi

if [ $LINT_ERRORS -gt 0 ]; then
  echo "FAIL ($LINT_ERRORS files)"
  ERRORS=$((ERRORS + LINT_ERRORS))
else
  echo "OK"
fi

# ─── Check 3: No Forbidden Markers ───────────────────────────────────────
echo -n "  Forbidden markers... "
MARKER_HITS=""

for f in $STAGED_FILES; do
  # Skip binary files and this hook itself
  if file "$f" | grep -q "text"; then
    HITS=$(grep -n "TODO\|FIXME\|HACK\|XXX\|TEMP\|BROKEN" "$f" 2>/dev/null || true)
    if [ -n "$HITS" ]; then
      MARKER_HITS="$MARKER_HITS\n  $f:\n$HITS"
    fi
  fi
done

if [ -n "$MARKER_HITS" ]; then
  echo "FAIL"
  echo -e "    Forbidden markers found:$MARKER_HITS"
  echo ""
  echo "    These markers indicate incomplete work. Resolve them before committing."
  echo "    If intentional, use a tracking issue instead of inline markers."
  ERRORS=$((ERRORS + 1))
else
  echo "OK"
fi

# ─── Check 4: MANIFEST Schema Validation ─────────────────────────────────
echo -n "  MANIFEST schema... "
if echo "$STAGED_FILES" | grep -q "MANIFEST.json"; then
  if command -v jq &>/dev/null; then
    # Validate JSON syntax
    if ! jq empty MANIFEST.json 2>/dev/null; then
      echo "FAIL (invalid JSON)"
      ERRORS=$((ERRORS + 1))
    else
      # Validate required fields
      MISSING=$(jq -r '
        .features[]
        | select(.id == null or .status == null)
        | "Missing id or status in feature: \(.)"
      ' MANIFEST.json 2>/dev/null)

      INVALID_STATUS=$(jq -r '
        .features[]
        | select(.status != "passing" and .status != "failing" and .status != "in_progress" and .status != "blocked")
        | "Invalid status \"\(.status)\" for \(.id)"
      ' MANIFEST.json 2>/dev/null)

      if [ -n "$MISSING" ] || [ -n "$INVALID_STATUS" ]; then
        echo "FAIL"
        [ -n "$MISSING" ] && echo "    $MISSING"
        [ -n "$INVALID_STATUS" ] && echo "    $INVALID_STATUS"
        ERRORS=$((ERRORS + 1))
      else
        echo "OK"
      fi
    fi
  else
    echo "SKIP (jq not installed)"
  fi
else
  echo "OK (not modified)"
fi

# ─── Check 5: Structural Tests ───────────────────────────────────────────
echo -n "  Structural tests... "
if [ -f "scripts/structural-tests.sh" ]; then
  if ! bash scripts/structural-tests.sh --staged-only 2>/dev/null; then
    echo "FAIL"
    ERRORS=$((ERRORS + 1))
  else
    echo "OK"
  fi
else
  echo "SKIP (no structural tests configured)"
fi

# ─── Summary ──────────────────────────────────────────────────────────────
echo ""
if [ $ERRORS -gt 0 ]; then
  echo "PRE-COMMIT: BLOCKED ($ERRORS errors)"
  echo "Fix all errors above before committing."
  exit 1
else
  echo "PRE-COMMIT: PASSED"
  exit 0
fi
```

---

### Component 2: Structural Tests

Structural tests verify the *shape* of the codebase, not its runtime behavior. They run as part of pre-commit and the E2E verification suite.

**Implementation:** `scripts/structural-tests.sh`

```bash
#!/bin/bash
# structural-tests.sh — Verify codebase structure
set -euo pipefail

ERRORS=0
STAGED_ONLY="${1:-}"

get_files() {
  local pattern="$1"
  if [ "$STAGED_ONLY" = "--staged-only" ]; then
    git diff --cached --name-only --diff-filter=ACM | grep -E "$pattern" || true
  else
    find . -type f | grep -E "$pattern" | grep -v node_modules | grep -v build | grep -v .git || true
  fi
}

# ─── Test 1: File Size Limits ────────────────────────────────────────────
echo "Structural Test 1: File size limits"
MAX_LINES=500
OVERSIZED=$(get_files '\.(cpp|h|hpp|js|ts|py|rs)$')
for f in $OVERSIZED; do
  LINES=$(wc -l < "$f" 2>/dev/null || echo 0)
  if [ "$LINES" -gt "$MAX_LINES" ]; then
    echo "  FAIL: $f has $LINES lines (max: $MAX_LINES)"
    echo "        Split this file into smaller, focused modules."
    ERRORS=$((ERRORS + 1))
  fi
done
[ $ERRORS -eq 0 ] && echo "  PASS"

# ─── Test 2: Module Boundary Validation ──────────────────────────────────
echo "Structural Test 2: Module boundaries"
if [ -f ".titan/architecture-rules.json" ]; then
  LAYERS=$(jq -r '.dependency_layers[]' .titan/architecture-rules.json)
  DIRECTION=$(jq -r '.dependency_direction' .titan/architecture-rules.json)

  if [ "$DIRECTION" = "down_only" ]; then
    # Check that lower layers don't import from higher layers
    LAYER_ARRAY=($(echo "$LAYERS"))
    for i in "${!LAYER_ARRAY[@]}"; do
      CURRENT="${LAYER_ARRAY[$i]}"
      for j in $(seq $((i + 1)) $((${#LAYER_ARRAY[@]} - 1))); do
        HIGHER="${LAYER_ARRAY[$j]}"
        # Check if current layer imports from higher layer
        VIOLATIONS=$(grep -rn "#include.*$HIGHER/" "src/$CURRENT/" 2>/dev/null || true)
        VIOLATIONS="$VIOLATIONS$(grep -rn "import.*from.*$HIGHER" "src/$CURRENT/" 2>/dev/null || true)"
        if [ -n "$VIOLATIONS" ]; then
          echo "  FAIL: $CURRENT imports from $HIGHER (dependency direction is down-only)"
          echo "$VIOLATIONS" | sed 's/^/    /'
          ERRORS=$((ERRORS + 1))
        fi
      done
    done
  fi
  [ $ERRORS -eq 0 ] && echo "  PASS"
else
  echo "  SKIP (no architecture-rules.json)"
fi

# ─── Test 3: Naming Conventions ──────────────────────────────────────────
echo "Structural Test 3: Naming conventions"
# Source files should be PascalCase or snake_case depending on language
CPP_FILES=$(get_files '\.(cpp|h|hpp)$')
for f in $CPP_FILES; do
  BASENAME=$(basename "$f" | sed 's/\..*//')
  # C++ files should be PascalCase
  if ! echo "$BASENAME" | grep -qE '^[A-Z][a-zA-Z0-9]*$'; then
    # Allow snake_case for test files
    if ! echo "$f" | grep -q "test"; then
      echo "  WARNING: $f — C++ files should use PascalCase naming"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done
echo "  PASS (${WARNINGS:-0} warnings)"

# ─── Test 4: Test Coverage Thresholds ────────────────────────────────────
echo "Structural Test 4: Test file presence"
SOURCE_FILES=$(get_files '\.(cpp|js|ts|py|rs)$' | grep -v test | grep -v spec || true)
MISSING_TESTS=0
for f in $SOURCE_FILES; do
  DIR=$(dirname "$f")
  BASE=$(basename "$f" | sed 's/\..*//')
  # Check if corresponding test file exists
  TEST_EXISTS=$(find "$DIR" "$(dirname "$DIR")/test" "$(dirname "$DIR")/tests" \
    -name "${BASE}Test.*" -o -name "${BASE}.test.*" -o -name "test_${BASE}.*" \
    2>/dev/null | head -1 || true)
  if [ -z "$TEST_EXISTS" ]; then
    MISSING_TESTS=$((MISSING_TESTS + 1))
  fi
done
TOTAL_SOURCE=$(echo "$SOURCE_FILES" | wc -w)
if [ "$TOTAL_SOURCE" -gt 0 ]; then
  COVERAGE_RATIO=$(echo "scale=2; ($TOTAL_SOURCE - $MISSING_TESTS) / $TOTAL_SOURCE" | bc 2>/dev/null || echo "0")
  REQUIRED=$(jq -r '.required_test_coverage // 0.70' .titan/architecture-rules.json 2>/dev/null || echo "0.70")
  echo "  Test file coverage: $COVERAGE_RATIO (required: $REQUIRED)"
  if [ "$(echo "$COVERAGE_RATIO < $REQUIRED" | bc 2>/dev/null)" = "1" ]; then
    echo "  FAIL: Test coverage below threshold"
    ERRORS=$((ERRORS + 1))
  else
    echo "  PASS"
  fi
else
  echo "  SKIP (no source files)"
fi

# ─── Summary ─────────────────────────────────────────────────────────────
echo ""
if [ $ERRORS -gt 0 ]; then
  echo "STRUCTURAL TESTS: FAILED ($ERRORS errors)"
  exit 1
else
  echo "STRUCTURAL TESTS: PASSED"
  exit 0
fi
```

---

### Component 3: Architecture Rules

A declarative JSON schema that defines the project's architectural constraints. Loaded during session orientation and enforced by structural tests.

**File:** `.titan/architecture-rules.json`

```json
{
  "project": "MyPlugin",
  "version": "1.0",

  "dependency_layers": ["types", "core", "dsp", "service", "ui"],
  "dependency_direction": "down_only",

  "module_boundaries": {
    "types": {
      "description": "Pure data types, no logic, no dependencies",
      "allowed_imports": [],
      "max_files": 20,
      "path": "src/types"
    },
    "core": {
      "description": "Core algorithms and utilities",
      "allowed_imports": ["types"],
      "max_files": 30,
      "path": "src/core"
    },
    "dsp": {
      "description": "Digital signal processing",
      "allowed_imports": ["types", "core"],
      "max_files": 40,
      "path": "src/dsp"
    },
    "service": {
      "description": "Business logic and state management",
      "allowed_imports": ["types", "core", "dsp"],
      "max_files": 30,
      "path": "src/service"
    },
    "ui": {
      "description": "User interface components",
      "allowed_imports": ["types", "core", "service"],
      "max_files": 50,
      "path": "src/ui"
    }
  },

  "max_file_lines": 500,
  "max_function_lines": 50,
  "max_parameters": 6,

  "required_test_coverage": 0.70,

  "naming_conventions": {
    "cpp_files": "PascalCase",
    "hpp_files": "PascalCase",
    "test_files": "{Name}Test.cpp",
    "classes": "PascalCase",
    "functions": "camelCase",
    "constants": "UPPER_SNAKE_CASE",
    "namespaces": "lower_snake_case"
  },

  "forbidden_patterns": [
    { "pattern": "TODO", "reason": "Use tracking issues, not inline TODOs" },
    { "pattern": "FIXME", "reason": "Fix now or create an issue" },
    { "pattern": "HACK", "reason": "Refactor instead of hacking" },
    { "pattern": "using namespace std", "reason": "Pollutes global namespace" },
    { "pattern": "sleep\\(", "reason": "No sleeps in production code; use async patterns" }
  ],

  "required_files": [
    "MANIFEST.json",
    "PROGRESS.md",
    "README.md",
    "CMakeLists.txt"
  ]
}
```

### Adapting Rules Per Domain

The architecture rules schema is project-agnostic. Here are examples for different domains:

**Web App:**
```json
{
  "dependency_layers": ["types", "utils", "hooks", "components", "pages"],
  "dependency_direction": "down_only",
  "max_file_lines": 300,
  "naming_conventions": {
    "components": "PascalCase",
    "hooks": "useCamelCase",
    "utils": "camelCase"
  }
}
```

**Rust CLI:**
```json
{
  "dependency_layers": ["types", "core", "commands", "cli"],
  "dependency_direction": "down_only",
  "max_file_lines": 400,
  "naming_conventions": {
    "files": "snake_case",
    "structs": "PascalCase",
    "functions": "snake_case"
  }
}
```

---

### Component 4: Linter Errors as Teaching Context

Every enforcement error must include three things:

1. **WHAT** is wrong (the specific violation)
2. **WHY** it is wrong (the architectural reason)
3. **HOW** to fix it (concrete action with example)

This transforms enforcement from a wall of "FAIL" messages into a learning system.

**Error Template:**

```
VIOLATION: {what}
  File: {file}:{line}
  Rule: {rule_id}

  WHY: {explanation of why this rule exists}

  FIX: {concrete steps to resolve}
  Example:
    Before: {bad code}
    After:  {good code}

  Reference: {link to architecture-rules.json or docs}
```

**Example Errors:**

```
VIOLATION: File exceeds 500 line limit (currently 623 lines)
  File: src/dsp/Reverb.cpp
  Rule: max_file_lines

  WHY: Large files are hard to understand, test, and review. They often
  indicate a class is doing too many things (violating Single Responsibility).

  FIX: Split this file into focused modules:
    - Extract early reflections into EarlyReflections.cpp
    - Extract diffusion network into DiffusionNetwork.cpp
    - Keep Reverb.cpp as the orchestrator (~200 lines)

  Reference: .titan/architecture-rules.json → max_file_lines
```

```
VIOLATION: Module boundary violation — UI imports from DSP
  File: src/ui/SpectrumDisplay.cpp:14
  Rule: dependency_direction (down_only)

  WHY: UI should never depend directly on DSP code. This creates tight
  coupling that makes both layers harder to test and modify independently.
  Changes to DSP internals should not break UI code.

  FIX: Introduce a service-layer intermediary:
    Before: #include "dsp/FFTProcessor.h"
    After:  #include "service/SpectrumData.h"

  Create a SpectrumData service that reads from FFTProcessor and
  provides a UI-friendly interface.

  Reference: .titan/architecture-rules.json → module_boundaries → ui
```

```
VIOLATION: Forbidden marker found: TODO
  File: src/core/AudioBuffer.cpp:87
  Rule: forbidden_patterns

  WHY: TODO markers indicate incomplete work. If code is committed with
  TODOs, they tend to accumulate and never get resolved. Every piece of
  committed code should be complete.

  FIX: Either:
    1. Complete the TODO now before committing
    2. Create a tracking issue and remove the TODO:
       - Add feature to MANIFEST.json with status "failing"
       - Remove the TODO comment
       - The loop will implement it in a future session

  Reference: .titan/architecture-rules.json → forbidden_patterns
```

---

## Integration: How Enforcement Connects

```
┌─────────────────────────────────────────────────┐
│                  git commit                      │
│                      │                           │
│                      ▼                           │
│            Pre-Commit Hook                       │
│          ┌────────────────────┐                  │
│          │ 1. Format check    │                  │
│          │ 2. Lint check      │                  │
│          │ 3. Forbidden marks │                  │
│          │ 4. MANIFEST schema │                  │
│          │ 5. Structural tests│                  │
│          └────────┬───────────┘                  │
│                   │                              │
│          PASS?────┼────NO → Reject + teach       │
│           │       │                              │
│          YES      │                              │
│           │       │                              │
│           ▼       │                              │
│      Commit OK    │                              │
│                   │                              │
│ ──────────────────┼──── Later ──────────────     │
│                   │                              │
│          E2E Verification Suite                   │
│          ┌────────────────────┐                  │
│          │ Full structural    │                  │
│          │ tests (all files)  │                  │
│          │ + Architecture     │                  │
│          │   rules audit      │                  │
│          └────────────────────┘                  │
│                                                  │
│ ──────────────────┼──── Session Start ──────     │
│                   │                              │
│          Session Orientation                      │
│          ┌────────────────────┐                  │
│          │ Load architecture  │                  │
│          │ rules into context │                  │
│          │ → Agent knows the  │                  │
│          │   rules BEFORE     │                  │
│          │   writing code     │                  │
│          └────────────────────┘                  │
└─────────────────────────────────────────────────┘
```

### Timing of Each Component

| Component | When It Runs | Scope |
|-----------|-------------|-------|
| Pre-commit hooks | Every `git commit` | Staged files only |
| Structural tests (staged) | Every `git commit` (via hook) | Staged files only |
| Structural tests (full) | E2E verification suite | Entire codebase |
| Architecture rules | Session orientation (read) + structural tests (enforce) | Entire codebase |
| Teaching errors | Whenever any check fails | Per violation |

---

## Setting Up Enforcement

### Quick Start

```bash
# 1. Create architecture rules
mkdir -p .titan
cp templates/architecture-rules.json .titan/architecture-rules.json
# Edit rules for your project

# 2. Install pre-commit hook
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 3. Create structural test script
cp templates/structural-tests.sh scripts/structural-tests.sh
chmod +x scripts/structural-tests.sh

# 4. Verify everything works
git add -A
git commit -m "test: verify enforcement" --dry-run
```

### Gradual Adoption

You do not need to enable all rules at once. Start with:

1. **Phase 1:** Formatting + forbidden markers (easy wins)
2. **Phase 2:** File size limits + MANIFEST validation
3. **Phase 3:** Module boundaries + dependency direction
4. **Phase 4:** Full structural tests + coverage thresholds

Adjust thresholds in `architecture-rules.json` as the codebase matures.

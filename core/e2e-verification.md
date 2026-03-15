# End-to-End Verification Harness

**Upgrade 15 — Phase 6: Autonomous Loop Engine**

Adds a full E2E verification layer on top of unit tests. No feature may transition from `"failing"` to `"passing"` in MANIFEST.json without passing its domain-specific E2E verification sequence.

---

## Why E2E Verification Exists

Unit tests prove individual functions work. E2E verification proves the **feature works as a user would experience it**. A plugin that compiles and passes unit tests can still crash in a DAW, produce silence, or render a broken UI. E2E catches what unit tests miss.

---

## Domain-Specific Strategies

| Domain | E2E Approach | Tooling |
|--------|-------------|---------|
| Audio Plugin (VST/AU) | Build -> pluginval -> test host -> signal test -> UI screenshot | cmake/make, pluginval CLI, REAPER/test host, sox/ffmpeg, screenshot diff |
| Web App | Dev server -> Puppeteer/Playwright -> DOM verification -> visual regression | npm/vite, playwright CLI, pixelmatch |
| CLI Tool | Run with known inputs -> verify stdout/stderr/exit codes/output files | bash, diff, file checksums |
| API | Start server -> HTTP requests -> verify responses -> check DB state | bash/curl, jq, sqlite3/psql |
| Desktop App | Launch -> accessibility tree -> simulated input -> window state | platform-specific a11y tools, xdotool/AppleScript |
| Mobile App | Build -> emulator launch -> UI automation -> screenshot | Xcode/Gradle, Appium/XCTest/Espresso |
| Library/SDK | Build -> run integration tests -> verify public API -> check docs | language-native test runner, doc generator |

---

## Audio Plugin: 7-Step Verification Sequence

Audio plugins require the most rigorous E2E pipeline due to real-time constraints, host compatibility, and signal integrity requirements.

### Step 1: Build Verification

```bash
# Clean build from scratch
rm -rf build/
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release

# Verify artifacts exist
PLUGIN_PATH="build/MyPlugin_artefacts/Release"
test -f "$PLUGIN_PATH/VST3/MyPlugin.vst3/Contents/MacOS/MyPlugin" || exit 1
test -f "$PLUGIN_PATH/AU/MyPlugin.component/Contents/MacOS/MyPlugin" || exit 1
```

**Pass criteria:** All target formats (VST3, AU, AAX) produce binaries with non-zero size.

### Step 2: pluginval Validation

```bash
# Run pluginval at strictness level 10
pluginval --validate "$PLUGIN_PATH/VST3/MyPlugin.vst3" \
  --strictness-level 10 \
  --timeout-ms 60000 \
  --verbose

# Exit code 0 = pass
```

**Pass criteria:** pluginval exits 0 at strictness level 10. Any failure here is a hard blocker.

### Step 3: Test Host Load

```bash
# Load in a headless test host and verify it reports correct metadata
test-host --load "$PLUGIN_PATH/VST3/MyPlugin.vst3" \
  --query name,vendor,category,num_inputs,num_outputs,num_parameters \
  --format json > /tmp/plugin-meta.json

# Verify expected values
jq -e '.num_inputs == 2 and .num_outputs == 2' /tmp/plugin-meta.json || exit 1
```

**Pass criteria:** Plugin loads, reports correct channel configuration, parameter count, and metadata.

### Step 4: Signal Integrity Test

```bash
# Process known input and verify output
test-host --load "$PLUGIN_PATH/VST3/MyPlugin.vst3" \
  --input test-assets/sine-440hz-1s.wav \
  --output /tmp/processed.wav \
  --sample-rate 44100 \
  --block-size 512

# Verify output is not silence
sox /tmp/processed.wav -n stat 2>&1 | grep "Maximum amplitude" | awk '{
  if ($3 == 0.000000) exit 1
}'

# Verify output matches expected reference (within tolerance)
python3 scripts/compare-audio.py \
  --reference test-assets/expected-output.wav \
  --actual /tmp/processed.wav \
  --tolerance-db 0.1
```

**Pass criteria:** Output is not silence, not clipping, and matches reference within tolerance.

### Step 5: Parameter Automation Test

```bash
# Automate parameter changes and verify they take effect
test-host --load "$PLUGIN_PATH/VST3/MyPlugin.vst3" \
  --input test-assets/sine-440hz-1s.wav \
  --automate "gain:0.0@0s,1.0@0.5s" \
  --output /tmp/automated.wav

# First half should be quieter than second half
python3 scripts/verify-automation.py /tmp/automated.wav \
  --expect "rms_first_half < rms_second_half"
```

**Pass criteria:** Parameter changes produce audible, measurable differences in output.

### Step 6: UI Verification

```bash
# Launch plugin UI and capture screenshot
test-host --load "$PLUGIN_PATH/VST3/MyPlugin.vst3" \
  --show-editor \
  --screenshot /tmp/plugin-ui.png \
  --wait-ms 2000

# Verify screenshot is not blank/black
python3 scripts/verify-screenshot.py /tmp/plugin-ui.png \
  --min-unique-colors 10 \
  --reference test-assets/ui-reference.png \
  --max-diff-percent 5.0
```

**Pass criteria:** UI renders, is not blank, and matches reference within 5% pixel difference.

### Step 7: Resource & Stability Test

```bash
# Run stress test: process 60 seconds of audio and monitor resources
test-host --load "$PLUGIN_PATH/VST3/MyPlugin.vst3" \
  --input test-assets/pink-noise-60s.wav \
  --output /dev/null \
  --monitor-resources \
  --report /tmp/resource-report.json

# Check for issues
jq -e '
  .peak_cpu_percent < 50 and
  .memory_leak_detected == false and
  .xruns == 0 and
  .crashes == 0
' /tmp/resource-report.json || exit 1
```

**Pass criteria:** CPU under 50%, no memory leaks, zero xruns, zero crashes over 60s.

---

## Verification Rules

### Rule 1: MANIFEST Status Gate

Feature status in `MANIFEST.json` may ONLY transition from `"failing"` to `"passing"` after the full E2E verification sequence completes successfully.

```
# WRONG: marking passing after unit tests
"feature_3": { "status": "passing" }   # <- only unit tests ran

# RIGHT: marking passing after E2E
"feature_3": { "status": "passing", "e2e_verified": true, "verified_at": "2026-03-15T14:30:00Z" }
```

### Rule 2: Log All Results

Every E2E run MUST be logged in `PROGRESS.md`:

```markdown
## Session 7 — E2E Verification Results

| Feature | Steps Passed | Steps Failed | Status | Duration |
|---------|-------------|-------------|--------|----------|
| feature_1_gain | 7/7 | 0 | PASS | 45s |
| feature_2_filter | 5/7 | 2 (signal, UI) | FAIL | 38s |

### Failures
- **feature_2_filter / Signal Test**: Output RMS deviation 2.3dB from reference (tolerance: 0.1dB)
- **feature_2_filter / UI Test**: Screenshot diff 12.4% (threshold: 5.0%)
```

### Rule 3: Fix-and-Reverify Loop

If E2E verification fails:

1. Diagnose the failure from the E2E log output
2. Fix the code
3. Re-run the FULL E2E sequence (not just the failing step)
4. Only mark passing if all steps pass

This pairs with the Oracle Loop: the E2E harness provides the ground truth that the Oracle checks against.

### Rule 4: No Partial Passes

A feature either passes ALL E2E steps or it remains `"failing"`. There is no partial credit.

---

## Verification Script Template

```bash
#!/bin/bash
# e2e-verify.sh — Run E2E verification for a specific feature
# Usage: ./e2e-verify.sh <feature_id> <domain>

set -euo pipefail

FEATURE_ID="$1"
DOMAIN="${2:-auto}"
RESULTS_FILE=".titan/e2e-results/${FEATURE_ID}.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p .titan/e2e-results

echo "{ \"feature\": \"$FEATURE_ID\", \"domain\": \"$DOMAIN\", \"started_at\": \"$TIMESTAMP\", \"steps\": [] }" > "$RESULTS_FILE"

run_step() {
  local step_name="$1"
  local step_cmd="$2"
  local start_time=$(date +%s)

  echo "  [$step_name] Running..."

  if eval "$step_cmd" > ".titan/e2e-results/${FEATURE_ID}_${step_name}.log" 2>&1; then
    local duration=$(( $(date +%s) - start_time ))
    echo "  [$step_name] PASSED (${duration}s)"
    # Append to results JSON
    return 0
  else
    local duration=$(( $(date +%s) - start_time ))
    echo "  [$step_name] FAILED (${duration}s)"
    return 1
  fi
}

# Domain detection if "auto"
if [ "$DOMAIN" = "auto" ]; then
  if [ -f "CMakeLists.txt" ] && grep -q "juce" CMakeLists.txt 2>/dev/null; then
    DOMAIN="audio_plugin"
  elif [ -f "package.json" ] && grep -q "react\|vue\|next\|svelte" package.json 2>/dev/null; then
    DOMAIN="web_app"
  elif [ -f "Cargo.toml" ] || [ -f "setup.py" ]; then
    DOMAIN="cli_tool"
  else
    DOMAIN="cli_tool"  # safe default
  fi
  echo "Auto-detected domain: $DOMAIN"
fi

PASS_COUNT=0
FAIL_COUNT=0
TOTAL=0

# Run domain-specific steps
case "$DOMAIN" in
  audio_plugin)
    TOTAL=7
    run_step "build" "scripts/e2e/audio-build.sh" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "pluginval" "scripts/e2e/audio-pluginval.sh" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "host_load" "scripts/e2e/audio-host-load.sh" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "signal" "scripts/e2e/audio-signal.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "parameter" "scripts/e2e/audio-parameter.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "ui" "scripts/e2e/audio-ui.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "resources" "scripts/e2e/audio-resources.sh" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    ;;
  web_app)
    TOTAL=4
    run_step "dev_server" "scripts/e2e/web-server.sh" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "browser_tests" "scripts/e2e/web-browser.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "dom_verify" "scripts/e2e/web-dom.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "visual_regression" "scripts/e2e/web-visual.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    ;;
  cli_tool)
    TOTAL=3
    run_step "run_inputs" "scripts/e2e/cli-run.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "verify_output" "scripts/e2e/cli-verify.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "exit_codes" "scripts/e2e/cli-exits.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    ;;
  api)
    TOTAL=4
    run_step "start_server" "scripts/e2e/api-server.sh" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "http_requests" "scripts/e2e/api-requests.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "verify_responses" "scripts/e2e/api-responses.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    run_step "db_state" "scripts/e2e/api-db.sh $FEATURE_ID" && ((PASS_COUNT++)) || ((FAIL_COUNT++))
    ;;
esac

# Final verdict
if [ "$FAIL_COUNT" -eq 0 ]; then
  echo ""
  echo "E2E VERIFICATION: PASS ($PASS_COUNT/$TOTAL steps)"
  echo "Feature $FEATURE_ID may transition to 'passing' in MANIFEST.json"
  exit 0
else
  echo ""
  echo "E2E VERIFICATION: FAIL ($PASS_COUNT/$TOTAL passed, $FAIL_COUNT/$TOTAL failed)"
  echo "Feature $FEATURE_ID remains 'failing' — review logs in .titan/e2e-results/"
  exit 1
fi
```

---

## Integration Points

| Component | How E2E Connects |
|-----------|-----------------|
| MANIFEST.json | Status gate — only E2E can flip failing to passing |
| PROGRESS.md | All results logged per session |
| Oracle Loop | E2E provides ground truth for Oracle verification |
| Loop Controller (Upgrade 16) | E2E runs as step 3 in every loop iteration |
| Enforcement Layer (Upgrade 19) | E2E scripts are themselves subject to structural tests |
| Session Orientation (Upgrade 13) | Reports E2E pass/fail counts during orientation |

---

## Adding E2E Steps for a New Domain

1. Create scripts in `scripts/e2e/<domain>-<step>.sh`
2. Add a case block in `e2e-verify.sh`
3. Document the steps in this spec
4. Each script must: exit 0 on pass, exit non-zero on fail, write details to stdout/stderr
5. Scripts should be idempotent (safe to re-run)

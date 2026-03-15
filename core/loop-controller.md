# Autonomous Loop Controller

**Upgrade 16 — Phase 6: Autonomous Loop Engine**

Orchestrates continuous development sessions, driving features from `"failing"` to `"passing"` without human intervention. The loop runs until all features pass, an escalation is triggered, or the user stops it.

---

## Loop Architecture

```
while (MANIFEST has failing features AND no escalation AND not stopped):
  1. Run Session Orientation (Upgrade 13)
  2. Execute Coding Agent on next feature
  3. Run E2E Verification (Upgrade 15)
  4. Checkpoint (git + PROGRESS + STATE)
  5. Evaluate loop health
  6. If healthy -> continue
  7. If unhealthy -> escalate
```

### Detailed Step Breakdown

**Step 1 — Session Orientation:**
Load MANIFEST.json, read PROGRESS.md tail, check context zone, identify next feature by priority. This grounds the session with full project awareness.

**Step 2 — Execute Coding Agent:**
The coding agent implements or continues work on the selected feature. It reads relevant source files, writes code, runs unit tests. This is the primary work step.

**Step 3 — E2E Verification:**
Run the domain-specific E2E verification harness (Upgrade 15). This is the truth gate: code either works end-to-end or it does not.

**Step 4 — Checkpoint:**
- `git add -A && git commit` with descriptive message
- Update PROGRESS.md with session results
- Update LOOP-STATE.json with current status

**Step 5 — Evaluate Loop Health:**
Check all health conditions (see table below). Any threshold violation triggers the appropriate action.

**Step 6/7 — Continue or Escalate:**
If healthy, loop back to step 1. If unhealthy, write an escalation report and pause/stop.

---

## LOOP-STATE.json

The loop controller maintains state in `.titan/LOOP-STATE.json`:

```json
{
  "status": "running",
  "started_at": "2026-03-15T10:00:00Z",
  "current_session": 12,
  "current_feature": "feature_5_reverb",
  "features_completed": 4,
  "features_remaining": 3,
  "consecutive_failures": 0,
  "last_error": null,
  "last_checkpoint": "2026-03-15T14:22:00Z",
  "error_history": [
    { "session": 8, "feature": "feature_3_filter", "error": "signal_test_rms_deviation", "resolved": true },
    { "session": 10, "feature": "feature_5_reverb", "error": "pluginval_strictness_10", "resolved": false }
  ],
  "escalation": null,
  "total_tokens_used": 847320,
  "budget_limit": 2000000
}
```

### Status Values

| Status | Meaning |
|--------|---------|
| `"running"` | Loop is actively executing sessions |
| `"paused"` | Loop stopped due to escalation, awaiting human input |
| `"stopped"` | Loop stopped by user or completion |
| `"completed"` | All features in MANIFEST are passing |
| `"error"` | Loop stopped due to environment or infrastructure failure |

---

## Loop Health Evaluation

After every session, evaluate ALL of these conditions:

| Condition | Threshold | Action | Severity |
|-----------|-----------|--------|----------|
| THRASH_DETECTED | Same error appears 3 times across sessions | Pause + escalate | HIGH |
| STALL_DETECTED | 0 features completed in 3 consecutive sessions | Pause + escalate | HIGH |
| REGRESSION_DETECTED | A previously passing feature now fails | Stop, fix regression first | CRITICAL |
| CONTEXT_EXHAUSTION | Context hits RED zone before feature is complete | Checkpoint, start new session | LOW |
| CONSECUTIVE_FAILURES | 3+ E2E failures in a row (any feature) | Pause + escalate (architecture issue) | HIGH |
| ENVIRONMENT_BROKEN | init.sh or smoke test fails | Stop all, fix environment | CRITICAL |
| BUDGET_LIMIT | Token/cost estimate exceeds budget | Pause + notify user | MEDIUM |

### Detection Logic

**THRASH_DETECTED:**
```python
# Pseudocode
recent_errors = error_history[-6:]  # last 6 errors
for error_pattern in unique(recent_errors):
    if count(error_pattern in recent_errors) >= 3:
        return THRASH_DETECTED
```

**STALL_DETECTED:**
```python
last_3_sessions = sessions[-3:]
features_completed_in_last_3 = sum(s.features_completed for s in last_3_sessions)
if features_completed_in_last_3 == 0:
    return STALL_DETECTED
```

**REGRESSION_DETECTED:**
```python
for feature in manifest.features:
    if feature.previous_status == "passing" and feature.current_status == "failing":
        return REGRESSION_DETECTED, feature
```

---

## Escalation Report Format

When the loop escalates, it writes a structured report to `.titan/ESCALATION.md`:

```markdown
# Escalation Report

**Generated:** 2026-03-15T14:30:00Z
**Reason:** THRASH_DETECTED
**Feature:** feature_5_reverb
**Sessions Affected:** 10, 11, 12

## Error Pattern
pluginval fails at strictness level 10 with "instrument returned silence
during instrument test". Error appeared in sessions 10, 11, 12 with
identical stack trace.

## What Was Tried
- Session 10: Added output buffer initialization in processBlock()
- Session 11: Fixed voice allocation to ensure at least 1 active voice
- Session 12: Rewrote MIDI handling to trigger note-on before render

## Diagnosis
The issue appears to be in the voice lifecycle management. pluginval sends
MIDI note-on followed by an immediate render call. Our voice allocation
has a 1-buffer latency before producing output, causing the first buffer
to be silent.

## Recommended Action
- Option A: Add zero-latency voice start path for immediate rendering
- Option B: Pre-allocate a default voice that renders even without note-on
- Option C: Reduce voice startup latency to 0 samples

## Resume Command
After fixing, resume the loop:
```
titan loop resume
```
```

---

## Shell Script Implementation: titan-loop.sh

```bash
#!/bin/bash
# titan-loop.sh — Autonomous Loop Controller
# Invokes Claude Code sessions in a loop, checking LOOP-STATE.json between iterations.
#
# Usage:
#   ./titan-loop.sh [--max-sessions N] [--budget TOKENS] [--dry-run]

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────
MAX_SESSIONS="${1:---max-sessions}"
LOOP_STATE=".titan/LOOP-STATE.json"
MANIFEST="MANIFEST.json"
ESCALATION_FILE=".titan/ESCALATION.md"
LOG_FILE=".titan/LOOP-LOG.md"

# Parse arguments
MAX_SESSIONS=100
BUDGET_LIMIT=2000000
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --max-sessions) MAX_SESSIONS="$2"; shift 2 ;;
    --budget) BUDGET_LIMIT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# ─── Initialization ─────────────────────────────────────────────────────────
mkdir -p .titan

initialize_state() {
  if [ ! -f "$LOOP_STATE" ]; then
    cat > "$LOOP_STATE" << STATEEOF
{
  "status": "running",
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "current_session": 0,
  "current_feature": null,
  "features_completed": 0,
  "features_remaining": $(jq '[.features[] | select(.status == "failing")] | length' "$MANIFEST"),
  "consecutive_failures": 0,
  "last_error": null,
  "last_checkpoint": null,
  "error_history": [],
  "escalation": null,
  "total_tokens_used": 0,
  "budget_limit": $BUDGET_LIMIT
}
STATEEOF
    echo "Initialized LOOP-STATE.json"
  fi
}

# ─── State Helpers ───────────────────────────────────────────────────────────
get_status() {
  jq -r '.status' "$LOOP_STATE"
}

get_session_number() {
  jq -r '.current_session' "$LOOP_STATE"
}

get_remaining() {
  jq '[.features[] | select(.status == "failing")] | length' "$MANIFEST"
}

increment_session() {
  local new_session=$(( $(get_session_number) + 1 ))
  jq ".current_session = $new_session" "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"
}

update_status() {
  jq ".status = \"$1\"" "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"
}

record_error() {
  local feature="$1"
  local error="$2"
  local session=$(get_session_number)
  jq ".error_history += [{\"session\": $session, \"feature\": \"$feature\", \"error\": \"$error\", \"resolved\": false}] | .last_error = \"$error\" | .consecutive_failures += 1" \
    "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"
}

record_success() {
  jq '.consecutive_failures = 0 | .features_completed += 1 | .features_remaining -= 1' \
    "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"
}

# ─── Health Checks ───────────────────────────────────────────────────────────
check_health() {
  local status="healthy"
  local reason=""

  # THRASH_DETECTED: same error 3 times
  local thrash_count=$(jq '[.error_history[-6:] | group_by(.error)[] | select(length >= 3)] | length' "$LOOP_STATE" 2>/dev/null || echo 0)
  if [ "$thrash_count" -gt 0 ]; then
    status="unhealthy"
    reason="THRASH_DETECTED"
  fi

  # STALL_DETECTED: 0 features in 3 sessions
  # (checked by comparing features_completed across last 3 sessions)
  local consecutive_fails=$(jq '.consecutive_failures' "$LOOP_STATE")
  if [ "$consecutive_fails" -ge 3 ]; then
    status="unhealthy"
    reason="CONSECUTIVE_FAILURES"
  fi

  # BUDGET_LIMIT
  local tokens_used=$(jq '.total_tokens_used' "$LOOP_STATE")
  local budget=$(jq '.budget_limit' "$LOOP_STATE")
  if [ "$tokens_used" -ge "$budget" ]; then
    status="unhealthy"
    reason="BUDGET_LIMIT"
  fi

  # REGRESSION_DETECTED: check git diff of MANIFEST for passing->failing
  if git diff HEAD~1 "$MANIFEST" 2>/dev/null | grep -q '"passing".*"failing"'; then
    status="unhealthy"
    reason="REGRESSION_DETECTED"
  fi

  echo "$status:$reason"
}

# ─── Escalation ──────────────────────────────────────────────────────────────
escalate() {
  local reason="$1"
  local feature=$(jq -r '.current_feature // "unknown"' "$LOOP_STATE")

  update_status "paused"
  jq ".escalation = \"$reason\"" "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"

  cat > "$ESCALATION_FILE" << ESCEOF
# Escalation Report

**Generated:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Reason:** $reason
**Feature:** $feature
**Session:** $(get_session_number)

## Error History (Recent)
$(jq -r '.error_history[-5:][] | "- Session \(.session): \(.feature) — \(.error)"' "$LOOP_STATE")

## Resume Command
After fixing, resume the loop:
\`\`\`
./titan-loop.sh
\`\`\`
ESCEOF

  echo ""
  echo "============================================"
  echo "  LOOP ESCALATED: $reason"
  echo "  See $ESCALATION_FILE for details"
  echo "============================================"
}

# ─── Select Next Feature ─────────────────────────────────────────────────────
select_next_feature() {
  # Pick the highest-priority failing feature
  jq -r '
    [.features[] | select(.status == "failing")]
    | sort_by(.priority // 99)
    | .[0].id // empty
  ' "$MANIFEST"
}

# ─── Checkpoint ──────────────────────────────────────────────────────────────
checkpoint() {
  local session=$(get_session_number)
  local feature=$(jq -r '.current_feature // "unknown"' "$LOOP_STATE")

  # Git commit
  git add -A
  git commit -m "titan-loop: session $session checkpoint ($feature)" 2>/dev/null || true

  # Update timestamp
  jq ".last_checkpoint = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"" \
    "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"

  echo "Checkpoint saved (session $session)"
}

# ─── Run One Session ─────────────────────────────────────────────────────────
run_session() {
  local feature="$1"
  local session=$(get_session_number)

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Session $session — Feature: $feature"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Update state
  jq ".current_feature = \"$feature\"" "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"

  if [ "$DRY_RUN" = true ]; then
    echo "  [DRY RUN] Would invoke Claude Code for $feature"
    return 0
  fi

  # Step 2: Invoke Claude Code coding session
  local session_prompt="You are in an autonomous TITAN loop session.

Current feature: $feature
Session number: $session

Instructions:
1. Read MANIFEST.json to understand the feature requirements
2. Read PROGRESS.md for context on previous sessions
3. Implement or continue work on the feature
4. Run unit tests
5. When done, update PROGRESS.md with results

Focus ONLY on $feature. Do not work on other features."

  # Execute Claude Code session
  claude --print "$session_prompt" 2>&1 | tee ".titan/session-${session}.log"
  local session_exit=${PIPESTATUS[0]}

  # Step 3: Run E2E verification
  echo "  Running E2E verification..."
  if ./scripts/e2e-verify.sh "$feature" auto 2>&1 | tee -a ".titan/session-${session}.log"; then
    echo "  E2E: PASS"
    record_success
    # Update MANIFEST
    jq "(.features[] | select(.id == \"$feature\")).status = \"passing\" | (.features[] | select(.id == \"$feature\")).e2e_verified = true" \
      "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
    return 0
  else
    echo "  E2E: FAIL"
    local error_msg=$(tail -1 ".titan/session-${session}.log" | head -c 100)
    record_error "$feature" "$error_msg"
    return 1
  fi
}

# ─── Main Loop ───────────────────────────────────────────────────────────────
main() {
  echo "TITAN Autonomous Loop Controller"
  echo "================================"
  echo "Max sessions: $MAX_SESSIONS"
  echo "Budget limit: $BUDGET_LIMIT tokens"
  echo ""

  initialize_state

  # Resume check
  local current_status=$(get_status)
  if [ "$current_status" = "paused" ]; then
    echo "Resuming from paused state..."
    update_status "running"
    jq '.escalation = null | .consecutive_failures = 0' "$LOOP_STATE" > "$LOOP_STATE.tmp" && mv "$LOOP_STATE.tmp" "$LOOP_STATE"
  elif [ "$current_status" = "completed" ]; then
    echo "All features already completed. Nothing to do."
    exit 0
  fi

  update_status "running"

  # Environment smoke test
  if [ -f "init.sh" ]; then
    echo "Running environment smoke test..."
    if ! bash init.sh --check 2>/dev/null; then
      escalate "ENVIRONMENT_BROKEN"
      exit 1
    fi
  fi

  local session_count=0

  while true; do
    # Check remaining features
    local remaining=$(get_remaining)
    if [ "$remaining" -eq 0 ]; then
      update_status "completed"
      echo ""
      echo "ALL FEATURES PASSING. Loop complete."
      echo "Total sessions: $(get_session_number)"
      exit 0
    fi

    # Check session limit
    session_count=$((session_count + 1))
    if [ "$session_count" -gt "$MAX_SESSIONS" ]; then
      update_status "paused"
      echo "Max sessions ($MAX_SESSIONS) reached. Pausing."
      exit 0
    fi

    # Increment session
    increment_session

    # Select next feature
    local next_feature=$(select_next_feature)
    if [ -z "$next_feature" ]; then
      update_status "completed"
      echo "No more failing features. Loop complete."
      exit 0
    fi

    # Run the session
    run_session "$next_feature" || true  # Don't exit on feature failure

    # Checkpoint
    checkpoint

    # Health check
    local health_result=$(check_health)
    local health_status="${health_result%%:*}"
    local health_reason="${health_result##*:}"

    if [ "$health_status" = "unhealthy" ]; then
      escalate "$health_reason"
      exit 1
    fi

    echo "  Health: OK — continuing loop"
  done
}

# ─── Entry Point ─────────────────────────────────────────────────────────────
main "$@"
```

---

## Loop Commands

| Command | Action |
|---------|--------|
| `titan loop start` | Start the autonomous loop from current MANIFEST state |
| `titan loop start --max-sessions 10` | Limit to 10 sessions |
| `titan loop start --budget 500000` | Set token budget |
| `titan loop start --dry-run` | Preview what the loop would do |
| `titan loop pause` | Gracefully pause after current session |
| `titan loop resume` | Resume from paused state |
| `titan loop stop` | Force stop the loop |
| `titan loop status` | Show current LOOP-STATE.json |
| `titan loop history` | Show session-by-session results |

### Pause vs Stop

- **Pause** completes the current session, checkpoints, and waits. Resume picks up where it left off.
- **Stop** immediately terminates. The current session's work is still committed but may be incomplete.

---

## Feature Selection Strategy

Features are selected from MANIFEST.json in priority order:

1. **Regression fixes** — Any previously passing feature that now fails (highest priority)
2. **Blocking features** — Features that other features depend on
3. **Explicit priority** — The `priority` field in MANIFEST (lower number = higher priority)
4. **Ordering** — If all else is equal, features are selected in MANIFEST order

```json
{
  "features": [
    { "id": "feature_1_types", "status": "passing", "priority": 1 },
    { "id": "feature_2_dsp_core", "status": "failing", "priority": 2, "depends_on": ["feature_1_types"] },
    { "id": "feature_3_filter", "status": "failing", "priority": 3, "depends_on": ["feature_2_dsp_core"] },
    { "id": "feature_4_ui", "status": "failing", "priority": 4 }
  ]
}
```

In this example, `feature_2_dsp_core` would be selected next because it has the highest priority among failing features.

---

## Integration Points

| Component | Relationship |
|-----------|-------------|
| Session Orientation (Upgrade 13) | Step 1 of every loop iteration |
| E2E Verification (Upgrade 15) | Step 3 — the truth gate |
| Trigger Engine (Upgrade 17) | Can start, pause, or inject work into the loop |
| MANIFEST.json | Source of truth for feature status |
| PROGRESS.md | Cumulative log of all session results |
| .titan/LOOP-STATE.json | Loop controller state |
| .titan/ESCALATION.md | Generated on unhealthy conditions |

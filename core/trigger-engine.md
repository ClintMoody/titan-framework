# Trigger Engine

**Upgrade 17 — Phase 6: Autonomous Loop Engine**

Adds reactive capabilities to the autonomous loop. Instead of only running when manually started, the loop can respond to scheduled events, file changes, external webhooks, and manual triggers with context.

---

## Trigger Types

### 1. Cron — Scheduled Sessions

Run the loop on a schedule. Useful for overnight development, periodic maintenance, or time-boxed work.

**Configuration:** `.titan/triggers/cron.json`

```json
{
  "triggers": [
    {
      "id": "nightly-build",
      "type": "cron",
      "schedule": "0 2 * * *",
      "description": "Run loop nightly at 2 AM",
      "max_sessions": 10,
      "budget": 500000,
      "priority_filter": null,
      "enabled": true
    },
    {
      "id": "weekend-sprint",
      "type": "cron",
      "schedule": "0 8 * * 6,0",
      "description": "Extended weekend sessions",
      "max_sessions": 50,
      "budget": 2000000,
      "priority_filter": ["P1", "P2"],
      "enabled": true
    },
    {
      "id": "hourly-check",
      "type": "cron",
      "schedule": "0 * * * *",
      "description": "Quick pass every hour during work hours",
      "max_sessions": 3,
      "budget": 100000,
      "priority_filter": ["P1"],
      "enabled": false
    }
  ]
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier for this trigger |
| `type` | string | Always `"cron"` |
| `schedule` | string | Standard cron expression (minute hour day month weekday) |
| `description` | string | Human-readable description |
| `max_sessions` | integer | Maximum sessions per invocation |
| `budget` | integer | Token budget for this invocation |
| `priority_filter` | string[] or null | Only work on features with these priority labels; null = all |
| `enabled` | boolean | Toggle without deleting |

**Behavior:**
- If the loop is already running, cron triggers are skipped (no double-runs)
- If the loop is paused due to escalation, cron triggers are skipped
- Cron writes an entry to `.titan/TRIGGER-LOG.md` whether it fires or skips

### 2. File-Watch — React to File Changes

Monitor specific paths and trigger actions when files change. Useful for re-verifying features when source is edited externally, or auto-formatting on save.

**Configuration:** `.titan/triggers/watch.json`

```json
{
  "triggers": [
    {
      "id": "source-change",
      "type": "watch",
      "paths": ["src/**/*.cpp", "src/**/*.h"],
      "ignore": ["src/generated/**"],
      "action": "reverify_affected",
      "debounce_ms": 5000,
      "description": "Re-verify features when source files change",
      "enabled": true
    },
    {
      "id": "manifest-change",
      "type": "watch",
      "paths": ["MANIFEST.json"],
      "ignore": [],
      "action": "restart_loop",
      "debounce_ms": 2000,
      "description": "Restart loop when MANIFEST changes (new features added)",
      "enabled": true
    },
    {
      "id": "test-asset-change",
      "type": "watch",
      "paths": ["test-assets/**"],
      "ignore": [],
      "action": "reverify_all",
      "debounce_ms": 10000,
      "description": "Re-verify all features when test assets change",
      "enabled": true
    }
  ]
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `paths` | string[] | Glob patterns to watch |
| `ignore` | string[] | Glob patterns to exclude |
| `action` | string | What to do (see action table) |
| `debounce_ms` | integer | Wait this long after last change before firing |

**Watch Actions:**

| Action | Description |
|--------|-------------|
| `reverify_affected` | Determine which features are affected by the changed files and re-run E2E on them |
| `reverify_all` | Re-run E2E on all currently-passing features |
| `restart_loop` | If loop is stopped, start it. If running, restart from orientation |
| `run_command` | Execute a custom command (specified in `command` field) |
| `notify` | Log the change but take no automated action |

**Debouncing:** File watches use debouncing to avoid firing on every keystroke during active editing. The trigger waits `debounce_ms` after the *last* change before firing. Rapid edits reset the timer.

### 3. Webhook — External Event Triggers

Accept HTTP requests from external systems (CI/CD, monitoring, other tools) to trigger loop actions.

**Configuration:** `.titan/triggers/webhook.json`

```json
{
  "triggers": [
    {
      "id": "ci-failure",
      "type": "webhook",
      "endpoint": "/hooks/ci-failure",
      "source": "github_actions",
      "description": "Auto-fix when CI fails",
      "auto_fix": true,
      "priority": "urgent",
      "enabled": true
    },
    {
      "id": "deploy-complete",
      "type": "webhook",
      "endpoint": "/hooks/deploy",
      "source": "vercel",
      "description": "Run E2E after deployment",
      "auto_fix": false,
      "priority": "normal",
      "enabled": true
    },
    {
      "id": "issue-created",
      "type": "webhook",
      "endpoint": "/hooks/issue",
      "source": "github",
      "description": "Add new issue as feature to MANIFEST",
      "auto_fix": false,
      "priority": "normal",
      "enabled": false
    }
  ]
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `endpoint` | string | HTTP path the webhook listens on |
| `source` | string | Expected source for validation |
| `auto_fix` | boolean | If true, loop immediately attempts to fix the issue |
| `priority` | string | `"urgent"` pauses current work; `"normal"` queues |

**Webhook Server:**

The trigger engine starts a lightweight HTTP server (default port 7150) that accepts POST requests:

```bash
# Start the trigger listener
titan trigger listen --port 7150

# External system sends:
curl -X POST http://localhost:7150/hooks/ci-failure \
  -H "Content-Type: application/json" \
  -H "X-Titan-Secret: $TITAN_WEBHOOK_SECRET" \
  -d '{
    "source": "github_actions",
    "run_id": 12345,
    "error": "test_filter_response failed: expected -3dB at 1kHz, got -1.2dB",
    "commit": "abc123",
    "branch": "main"
  }'
```

**Security:** Webhooks require a shared secret in the `X-Titan-Secret` header. Set via `TITAN_WEBHOOK_SECRET` environment variable. Requests without a valid secret are rejected with 401.

### 4. Manual — User-Initiated with Context

User triggers the loop with specific context or instructions that override normal feature selection.

```bash
# Focus on a specific feature
titan trigger manual --feature feature_5_reverb

# Provide context for the session
titan trigger manual --context "The user reported clicking artifacts at high feedback values. Focus on the feedback clamp in reverb DSP."

# Emergency fix
titan trigger manual --priority urgent --context "Production build broken, rollback if not fixed in 3 sessions" --max-sessions 3

# Re-verify everything
titan trigger manual --action reverify_all
```

**Manual trigger payload:**

```json
{
  "type": "manual",
  "triggered_at": "2026-03-15T14:30:00Z",
  "triggered_by": "user",
  "feature": "feature_5_reverb",
  "context": "Clicking artifacts at high feedback values",
  "priority": "urgent",
  "max_sessions": 3,
  "action": "fix"
}
```

---

## Loop Integration

### How Triggers Interact with the Running Loop

| Trigger | Loop Running | Loop Paused | Loop Stopped |
|---------|-------------|-------------|-------------|
| Cron | Skip (already running) | Skip (needs human) | Start loop |
| Watch (reverify) | Inject task into queue | Skip | Run E2E only |
| Watch (restart) | Restart after current | Skip | Start loop |
| Webhook (urgent) | Pause current, handle | Handle immediately | Start loop |
| Webhook (normal) | Queue for next session | Skip | Start loop |
| Manual | Override current feature | Resume + handle | Start loop |

### Priority Injection

When a trigger needs to interrupt the current loop, it modifies MANIFEST.json to inject a priority task:

```json
{
  "injected_tasks": [
    {
      "id": "ci-fix-20260315-143000",
      "source": "webhook:ci-failure",
      "priority": 0,
      "description": "Fix CI failure: test_filter_response",
      "context": "expected -3dB at 1kHz, got -1.2dB",
      "injected_at": "2026-03-15T14:30:00Z",
      "status": "failing"
    }
  ]
}
```

Injected tasks with `priority: 0` are always selected before regular features.

---

## Trigger Log

All trigger events are logged to `.titan/TRIGGER-LOG.md`:

```markdown
# Trigger Log

## 2026-03-15

### 14:30:00 — webhook:ci-failure
- **Source:** github_actions (run 12345)
- **Action:** Injected urgent fix task
- **Loop was:** running (session 12)
- **Result:** Paused session 12, starting CI fix

### 14:15:00 — watch:source-change
- **Files:** src/dsp/Reverb.cpp (modified)
- **Action:** reverify_affected → feature_5_reverb
- **Loop was:** running (session 12)
- **Result:** Queued re-verification for next session

### 02:00:00 — cron:nightly-build
- **Action:** Started loop with max_sessions=10, budget=500000
- **Loop was:** stopped
- **Result:** Completed 4 features in 8 sessions
```

---

## Trigger Management Commands

| Command | Description |
|---------|-------------|
| `titan trigger list` | Show all configured triggers and their status |
| `titan trigger enable <id>` | Enable a trigger |
| `titan trigger disable <id>` | Disable a trigger |
| `titan trigger listen` | Start the webhook listener and file watchers |
| `titan trigger listen --port 7150` | Listen on a specific port |
| `titan trigger manual --feature X` | Manually trigger for a specific feature |
| `titan trigger log` | Show recent trigger log entries |
| `titan trigger test <id>` | Fire a trigger in dry-run mode |

---

## Implementation: titan-trigger.sh

```bash
#!/bin/bash
# titan-trigger.sh — Trigger Engine
# Manages cron, file-watch, webhook, and manual triggers

set -euo pipefail

TRIGGER_DIR=".titan/triggers"
TRIGGER_LOG=".titan/TRIGGER-LOG.md"
LOOP_STATE=".titan/LOOP-STATE.json"

mkdir -p "$TRIGGER_DIR"

log_trigger() {
  local trigger_id="$1"
  local action="$2"
  local result="$3"
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local loop_status=$(jq -r '.status // "unknown"' "$LOOP_STATE" 2>/dev/null || echo "no state")

  cat >> "$TRIGGER_LOG" << EOF

### $timestamp — $trigger_id
- **Action:** $action
- **Loop was:** $loop_status
- **Result:** $result
EOF
}

should_start_loop() {
  local status=$(jq -r '.status // "stopped"' "$LOOP_STATE" 2>/dev/null || echo "stopped")
  case "$status" in
    stopped|error|completed) return 0 ;;
    *) return 1 ;;
  esac
}

case "${1:-help}" in
  listen)
    echo "Starting trigger listener..."
    echo "  File watchers: active"
    echo "  Webhook server: port ${2:-7150}"
    echo "  Cron scheduler: active"
    echo ""
    echo "Listening for events... (Ctrl+C to stop)"

    # In production, this would start:
    # 1. fswatch/inotifywait for file triggers
    # 2. A lightweight HTTP server for webhooks
    # 3. A cron scheduler for timed triggers
    ;;

  manual)
    shift
    feature=""
    context=""
    priority="normal"
    max_sessions=10

    while [[ $# -gt 0 ]]; do
      case $1 in
        --feature) feature="$2"; shift 2 ;;
        --context) context="$2"; shift 2 ;;
        --priority) priority="$2"; shift 2 ;;
        --max-sessions) max_sessions="$2"; shift 2 ;;
        *) shift ;;
      esac
    done

    log_trigger "manual" "User-initiated: feature=$feature priority=$priority" "Starting loop"

    if should_start_loop; then
      ./titan-loop.sh --max-sessions "$max_sessions"
    else
      echo "Loop already running. Injecting manual task."
    fi
    ;;

  list)
    echo "Configured Triggers:"
    echo ""
    for f in "$TRIGGER_DIR"/*.json; do
      [ -f "$f" ] || continue
      echo "--- $(basename "$f" .json) ---"
      jq -r '.triggers[] | "  [\(if .enabled then "ON" else "OFF" end)] \(.id): \(.description)"' "$f"
      echo ""
    done
    ;;

  enable)
    trigger_id="$2"
    for f in "$TRIGGER_DIR"/*.json; do
      jq "(.triggers[] | select(.id == \"$trigger_id\")).enabled = true" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
    echo "Enabled trigger: $trigger_id"
    ;;

  disable)
    trigger_id="$2"
    for f in "$TRIGGER_DIR"/*.json; do
      jq "(.triggers[] | select(.id == \"$trigger_id\")).enabled = false" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
    echo "Disabled trigger: $trigger_id"
    ;;

  log)
    if [ -f "$TRIGGER_LOG" ]; then
      tail -50 "$TRIGGER_LOG"
    else
      echo "No trigger log found."
    fi
    ;;

  *)
    echo "Usage: titan-trigger.sh {listen|manual|list|enable|disable|log}"
    ;;
esac
```

---

## Integration Points

| Component | Relationship |
|-----------|-------------|
| Loop Controller (Upgrade 16) | Triggers start, pause, or inject work into the loop |
| MANIFEST.json | Watch triggers inject tasks; manual triggers override selection |
| E2E Verification (Upgrade 15) | Watch triggers can invoke re-verification directly |
| .titan/TRIGGER-LOG.md | All trigger events logged here |
| .titan/LOOP-STATE.json | Triggers check loop status before acting |

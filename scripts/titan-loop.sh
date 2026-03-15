#!/bin/bash
# TITAN v2.0 — Autonomous Loop Controller
# Runs coding agent sessions in a loop until all features pass or escalation needed.
#
# Usage: ./scripts/titan-loop.sh [--max-sessions N] [--from F-XXX]
#
# Prerequisites:
#   - .titan/MANIFEST.json exists
#   - .titan/LOOP-STATE.json exists
#   - claude (Claude Code CLI) is in PATH

set -euo pipefail

TITAN_DIR=".titan"
LOOP_STATE="$TITAN_DIR/LOOP-STATE.json"
MANIFEST="$TITAN_DIR/MANIFEST.json"
PROGRESS="$TITAN_DIR/PROGRESS.md"
CODING_PROMPT="$TITAN_DIR/prompts/coding-agent.md"
AGENTS_FILE="$TITAN_DIR/AGENTS.md"

MAX_SESSIONS=${1:-999}
SESSION_COOLDOWN=5

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[TITAN]${NC} $1"; }
warn() { echo -e "${YELLOW}[TITAN]${NC} $1"; }
error() { echo -e "${RED}[TITAN]${NC} $1"; }
success() { echo -e "${GREEN}[TITAN]${NC} $1"; }

# Preflight checks
if [ ! -f "$LOOP_STATE" ]; then
  error "LOOP-STATE.json not found. Run /titan:00-bootstrap first."
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  error "MANIFEST.json not found. Run /titan:00-bootstrap first."
  exit 1
fi

if ! command -v claude &> /dev/null; then
  error "Claude Code CLI not found in PATH."
  exit 1
fi

if ! command -v jq &> /dev/null; then
  error "jq not found. Install with: brew install jq (macOS) or apt install jq (Linux)"
  exit 1
fi

log "╔══════════════════════════════════════════════════════════════╗"
log "║  ⚡ TITAN — AUTONOMOUS LOOP                                  ║"
log "╚══════════════════════════════════════════════════════════════╝"
log ""

SESSION_COUNT=0

while [ $SESSION_COUNT -lt $MAX_SESSIONS ]; do
  # Read loop state
  STATUS=$(jq -r '.status' "$LOOP_STATE")
  FAILING=$(jq -r '.manifest_progress.failing' "$LOOP_STATE")
  ESCALATION=$(jq -r '.escalation_needed' "$LOOP_STATE")

  # Check termination conditions
  if [ "$STATUS" = "stopped" ] || [ "$STATUS" = "stopping" ]; then
    warn "Loop stopped by user request."
    break
  fi

  if [ "$ESCALATION" = "true" ]; then
    error "Escalation needed. Review .titan/ESCALATION-REPORT.md"
    break
  fi

  if [ "$FAILING" = "0" ]; then
    success "All features passing! Loop complete."
    break
  fi

  SESSION_COUNT=$((SESSION_COUNT + 1))
  CURRENT_SESSION=$(jq -r '.current_session' "$LOOP_STATE")
  NEXT_SESSION=$((CURRENT_SESSION + 1))

  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Session $NEXT_SESSION — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  log "  Features: $FAILING failing"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Update session count in LOOP-STATE
  jq --argjson session "$NEXT_SESSION" '.current_session = $session | .status = "running"' \
    "$LOOP_STATE" > "${LOOP_STATE}.tmp" && mv "${LOOP_STATE}.tmp" "$LOOP_STATE"

  # Run a coding agent session
  if [ -f "$CODING_PROMPT" ]; then
    claude --print "$(cat "$CODING_PROMPT")" 2>&1 || {
      warn "Session exited with non-zero status. Checking state..."
    }
  else
    claude --print "Read .titan/AGENTS.md and follow the autonomous coding session protocol. Implement the next failing feature from MANIFEST.json." 2>&1 || {
      warn "Session exited with non-zero status. Checking state..."
    }
  fi

  # Post-session health check
  if [ -f "$LOOP_STATE" ]; then
    ESCALATION=$(jq -r '.escalation_needed' "$LOOP_STATE")
    if [ "$ESCALATION" = "true" ]; then
      REASON=$(jq -r '.escalation_reason' "$LOOP_STATE")
      error "Session triggered escalation: $REASON"
      break
    fi
  fi

  log "Session $NEXT_SESSION complete. Cooling down ${SESSION_COOLDOWN}s..."
  sleep $SESSION_COOLDOWN
done

# Final status
PASSING=$(jq -r '.manifest_progress.passing' "$LOOP_STATE")
TOTAL=$(jq -r '.manifest_progress.total' "$LOOP_STATE")
log ""
log "╔══════════════════════════════════════════════════════════════╗"
log "║  LOOP COMPLETE                                               ║"
log "╚══════════════════════════════════════════════════════════════╝"
log "  Sessions run: $SESSION_COUNT"
log "  Features passing: $PASSING / $TOTAL"
log "  Status: $(jq -r '.status' "$LOOP_STATE")"

---
name: titan:autopilot-full
description: Full autonomous mode — walk-away execution with self-chaining across context windows
---

# /titan:autopilot-full — Full Autonomous Mode

Walk-away execution. Run plan-build-verify for all remaining phases without human intervention.

## Context Management

When context usage exceeds 60%:
1. Commit all current work
2. Update `.titan/progress.log` with current state
3. Spawn a fresh subagent with instructions: "Read .titan/progress.log and .titan/knowledge.md. Continue executing /titan:autopilot-full from current position. Do not re-plan completed phases."
4. Exit cleanly

The successor picks up with fresh context, reads progress.log, and continues. The chain continues until all phases complete or a BLOCKED task requires human input.

## Rate Limit Handling

Commit all work, update progress.log, spawn successor with instruction to wait 5 minutes before starting.

## Termination Conditions (do NOT spawn successor)

| Condition | Action |
|-----------|--------|
| All phases complete | Write `[COMPLETE]` to progress.log |
| Task BLOCKED needing human decision | Write `[NEEDS_HUMAN]` to progress.log |
| 3 consecutive successors failed to progress (same task 3x) | Write `[STUCK]` to progress.log |
| Verification fails requiring architecture decisions | Write `[VERIFY_FAILED]` to progress.log |

## Safety Guarantees

- Wave reconciliation (v2.3) runs after every wave
- Stuck detection taxonomy (v2.2) enforced — 3-failure limit before BLOCKED
- Progress log captures every state transition
- BLOCKED tasks are logged but never retried without new information

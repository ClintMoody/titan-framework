---
name: titan:capture
description: Capture a stray thought or note without interrupting current work
---

# /titan:capture — Background Capture

> Capture an idea, concern, or observation without breaking your flow. Appends to `.titan/captures.md` and returns you to work immediately.

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` first)

## Usage

```
/titan:capture <note>
```

Example:
```
/titan:capture We should add rate limiting to the public API before launch
/titan:capture The auth module has no tests — flag for next phase
/titan:capture Consider switching from REST to GraphQL for the dashboard queries
```

## Process

### Step 1 — Append to Captures File

1. If `.titan/captures.md` does not exist, create it with header:
   ```markdown
   # TITAN Captures
   > Stray thoughts, concerns, and ideas captured during work.
   > Triaged during `/titan:06-plan` (Step 3b).
   ```

2. Append the capture with ISO timestamp and status:
   ```markdown
   - [ ] [ISO-8601 timestamp] — <note text>
   ```

### Step 2 — Acknowledge and Return

Print exactly:
```
Captured.
```

Do NOT display the full captures file. Do NOT ask follow-up questions. Do NOT suggest next actions. The entire point is zero interruption.

## Outputs

| Artifact | Location | Description |
|----------|----------|-------------|
| captures.md | `.titan/captures.md` | Timestamped capture appended |

## State Updates

None. Captures do not modify STATE.md.

## Triage

Captures are triaged automatically during `/titan:06-plan` (Step 3b — Review Background Captures). Each capture is assessed for relevance to the phase being planned:
- **Relevant** captures become tasks, constraints, or risks in the plan
- **Irrelevant** captures are skipped (reviewed again at next planning cycle)
- **Stale** captures are marked as reviewed

## Tips

- Use captures for anything that crosses your mind during build or verify. Do not context-switch to address it.
- Captures are cheap. When in doubt, capture it.
- The planning phase triages captures automatically — you do not need to remember them.

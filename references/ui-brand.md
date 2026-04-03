# TITAN Visual Brand Standards

> All TITAN commands must follow these visual standards for consistent, professional output.

---

## Stage Banners

Every command starts with its stage banner:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — [STAGE NAME]                                     ║
╚══════════════════════════════════════════════════════════════╝
```

### Banner Text by Command

| Command | Banner Text |
|---------|------------|
| `/titan:01-init` | INITIALIZING |
| `/titan:02-vision` | VISION |
| `/titan:03-bootstrap` | BOOTSTRAPPING |
| `/titan:04-explore` | EXPLORING |
| `/titan:05-design` | DESIGN |
| `/titan:06-plan` | PLANNING |
| `/titan:07-build` | BUILDING |
| `/titan:08-verify` | VERIFYING |
| `/titan:09-ship` | SHIPPING |
| `/titan:scan` | SCANNING CODEBASE |
| `/titan:quick` | QUICK TASK |
| `/titan:debug` | DEBUGGING |
| `/titan:investigate` | INVESTIGATING |
| `/titan:experiment` | EXPERIMENT |
| `/titan:learn` | LEARNING |
| `/titan:review` | CODE REVIEW |
| `/titan:test` | TESTING |
| `/titan:audit` | AUDIT |
| `/titan:refactor` | REFACTORING |
| `/titan:resume` | RESUMING |
| `/titan:pause` | PAUSING |
| `/titan:progress` | PROGRESS |
| `/titan:autopilot` | AUTOPILOT |
| `/titan:settings` | SETTINGS |
| `/titan:help` | HELP |

### Completion Banner

```
╔══════════════════════════════════════════════════════════════╗
║  ★ TITAN — [STAGE] COMPLETE                                 ║
╚══════════════════════════════════════════════════════════════╝
```

### Milestone Banner

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ★  MILESTONE COMPLETE  ★                                  ║
║                                                              ║
║    [Project Name] v[X.Y.Z]                                   ║
║    [phases] phases · [tasks] tasks · [commits] commits       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Status Symbols

| Symbol | Meaning | Usage |
|--------|---------|-------|
| ✓ | Complete / Pass | Task complete, AC passed, check passed |
| ✗ | Failed / Blocked | Task failed, AC failed, check failed |
| ◆ | In Progress | Currently executing |
| ○ | Pending | Not yet started |
| ⚡ | Active / Current | Current phase or step |
| ⚠ | Warning / Attention | Non-blocking issue, caution |
| ★ | Milestone / Achievement | Phase complete, milestone shipped |

---

## Progress Display

### Phase Progress Bar
```
Phase 3 of 9 ▓▓▓▓▓░░░░░░░░░░░ 33%
```

### Task Progress
```
Tasks: 4/7 complete
  ✓ Create user model
  ✓ Add authentication middleware
  ✓ Build login endpoint
  ◆ Build registration endpoint
  ○ Add password reset
  ○ Write auth tests
  ○ Update API documentation
```

---

## Checkpoint Display

When a command needs user input or confirmation:

```
┌──────────────────────────────────────────────────────────────┐
│  ◆ CHECKPOINT: [type]                                        │
│                                                              │
│  [question or information]                                   │
│                                                              │
│  Options:                                                    │
│    1. [option 1]                                             │
│    2. [option 2]                                             │
│    3. [option 3]                                             │
└──────────────────────────────────────────────────────────────┘
```

---

## Agent Spawn Indicator

When spawning a subagent:

```
  ⚡ Spawning titan-[agent] agent...
     Task: [description]
     Model: [model name]
```

When agent completes:

```
  ✓ titan-[agent] complete — [brief result]
```

---

## Tables

Status tables use this format:

```
| Phase | Name              | Status         | Date       |
|-------|-------------------|----------------|------------|
| 01    | Project Setup     | ✓ Complete     | 2024-01-15 |
| 02    | Core Features     | ◆ In Progress  | —          |
| 03    | Polish & Testing  | ○ Pending      | —          |
```

---

## "Next Up" Block

After any command completes, show what to do next:

```
  ┌─────────────────────────────────────────┐
  │  Next: /titan:[command] — [description] │
  └─────────────────────────────────────────┘
```

---

## Visual Rules

1. **Banners are 62 characters wide** (inner width). Keep text within this width.
2. **One blank line** before and after banners.
3. **Status symbols are consistent** — always use the same symbol for the same meaning.
4. **Tables are aligned** — pad columns for readability.
5. **No emoji** except the defined status symbols. Keep it professional.
6. **Progress bars use ▓ and ░** — filled and empty blocks.
7. **Indentation uses 2 spaces** for nested content.

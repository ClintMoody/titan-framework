---
name: titan:settings
description: Configure TITAN preferences — model profile, domain, git behavior, context limits
---

# /titan:settings — Configuration Management

> Run this command to view or change TITAN project configuration.

## Prerequisites

- `.titan/` directory exists with `config.yaml`.

## Process

### Step 1: Display Settings Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — SETTINGS                                         ║
╚══════════════════════════════════════════════════════════════╝
```

### Step 2: Read Current Configuration

Read `.titan/config.yaml` and display current settings:

```
  Current Configuration
  ─────────────────────────────────────────────────

  1. Model Profile     [current value]
     Planning:    [model]
     Execution:   [model]
     Review:      [model]

  2. Domain            [current value]

  3. Execution Mode
     Prefer:      [prefer_in_session | prefer_agent]

  4. Git Settings
     Auto-commit:   [on|off]
     Auto-branch:   [on|off]
     Commit prefix:  [prefix]
     Branch pattern: [pattern]

  5. Context Settings
     Work unit target:      [N]%
     Max tasks per plan:    [N]
     Auto-shard threshold:  [N] lines

  ─────────────────────────────────────────────────
  Enter a number to change, or "done" to exit:
```

### Step 3: Handle User Selection

Wait for the user's choice and present the appropriate submenu:

#### Option 1: Model Profile

```
  Select Model Profile:
  ─────────────────────────────────────────────────

  1. quality    — Maximum quality, higher cost
                  Planning:  claude-opus-4-6
                  Execution: claude-opus-4-6
                  Review:    claude-opus-4-6

  2. balanced   — Good balance of quality and cost (recommended)
                  Planning:  claude-opus-4-6
                  Execution: claude-sonnet-4-6
                  Review:    claude-sonnet-4-6

  3. budget     — Cost-effective for experiments
                  Planning:  claude-sonnet-4-6
                  Execution: claude-haiku-4-5
                  Review:    claude-haiku-4-5

  Enter number or name [current]:
```

Update `profile` and the corresponding model assignments in config.yaml.

#### Option 2: Domain

```
  Select Domain:
  ─────────────────────────────────────────────────

  1. web            — Web application (React, Vue, Next.js, etc.)
  2. mobile         — Mobile app (iOS, Android, React Native, Flutter)
  3. desktop        — Desktop application (Electron, Tauri, native)
  4. audio          — Audio software (plugins, DAWs, DSP)
  5. game           — Game development (Unity, Godot, custom engine)
  6. data           — Data pipelines, analytics, ML/AI
  7. api            — API / backend service
  8. infrastructure — Infrastructure as code, DevOps, platform
  9. general        — Mixed / other

  Enter number or name [current]:
```

Update `project.domain` in config.yaml. Also update CLAUDE.md and AGENTS.md domain references.

Record the domain change in DECISIONS.md:
```
| [N] | [today] | Domain changed: [old] → [new] | [user's reason if given] | Yes — /titan:settings |
```

#### Option 3: Execution Mode

```
  Execution Preference:
  ─────────────────────────────────────────────────

  1. prefer_agent      — Use subagents for most tasks (better quality,
                         fresh context per task, higher token usage)

  2. prefer_in_session — Do most work in the current session (faster,
                         fewer tokens, but shares context window)

  Current: [value]
  Enter number [current]:
```

Update `execution.prefer` in config.yaml.

#### Option 4: Git Settings

```
  Git Settings:
  ─────────────────────────────────────────────────

  a. Auto-commit     [on|off]   — Automatically commit after each task
  b. Auto-branch     [on|off]   — Create branch per phase automatically
  c. Commit prefix   [value]    — Prefix for commit messages
  d. Branch pattern  [value]    — Pattern for branch names

  Enter letter to toggle/change, or "back":
```

For toggles (a, b): flip the current value.
For strings (c, d): prompt for new value with current as default.

Update corresponding fields in config.yaml.

#### Option 5: Context Settings

```
  Context Settings:
  ─────────────────────────────────────────────────

  a. Work unit target      [N]%    — Target context usage per plan (20-80)
  b. Max tasks per plan    [N]     — Maximum tasks in a single plan (1-10)
  c. Auto-shard threshold  [N]     — Lines before auto-sharding (100-2000)

  Enter letter to change, or "back":
```

Validate input ranges. Update corresponding fields in config.yaml.

### Step 4: Write Configuration

After any change:

1. Write updated `.titan/config.yaml` preserving all fields.
2. Print: `✓ Configuration updated.`
3. Return to the main settings menu (Step 2) to allow additional changes.

### Step 5: Exit

When user enters "done" or indicates they're finished:

```
  ✓ Settings saved to .titan/config.yaml

  Changes will take effect on the next command execution.
```

## Config File Format

The canonical config.yaml format:

```yaml
# TITAN Configuration
# Last modified: [ISO 8601 timestamp]

project:
  name: [project name]
  type: [greenfield|brownfield]
  domain: [domain]
  initialized: [ISO 8601 timestamp]

profile: [quality|balanced|budget]

profiles:
  quality:
    planning: claude-opus-4-6
    execution: claude-opus-4-6
    review: claude-opus-4-6
  balanced:
    planning: claude-opus-4-6
    execution: claude-sonnet-4-6
    review: claude-sonnet-4-6
  budget:
    planning: claude-sonnet-4-6
    execution: claude-haiku-4-5
    review: claude-haiku-4-5

execution:
  prefer: prefer_agent

context:
  brackets:
    fresh: 70
    moderate: 40
    deep: 20
    critical: 10
  work_unit_target: 50
  max_tasks_per_plan: 3
  auto_shard_threshold: 500

git:
  commit_prefix: "titan"
  branch_prefix: "titan/"
  auto_commit: true
  auto_branch: true

verification:
  mandatory: true
  adversarial: true
  min_issues: 1
```

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| config.yaml | `.titan/config.yaml` | Updated configuration |
| DECISIONS.md | `.titan/DECISIONS.md` | Decision record for significant changes |

## State Updates

- config.yaml updated with new values.
- DECISIONS.md gets new entry for domain or profile changes.
- CLAUDE.md and AGENTS.md updated if domain changes.

## Error Handling

| Error | Resolution |
|-------|-----------|
| config.yaml missing | Offer to recreate from defaults |
| config.yaml malformed | Attempt to parse what exists, fill defaults for missing fields |
| Invalid input | Show valid options, re-prompt |
| Write permission error | Alert user, suggest manual edit |

## What's Next

After settings are saved, display (as markdown, NOT in a code block):

---

### ★ Recommended

> **Continue with your current workflow.** Changes take effect on the next command.

### Other options

| Command | Action |
|---------|--------|
| `/titan:progress` | See your current position and what to do next |
| `/titan:resume` | Re-read state with the new settings applied |
| `/titan:help` | See all available commands |

---

## Tips

- The `balanced` profile is right for 90% of projects. Use `quality` for critical production systems. Use `budget` for quick experiments.
- `prefer_agent` gives better results for complex tasks but uses more tokens. `prefer_in_session` is faster for simple changes.
- Lower `max_tasks_per_plan` if plans are too large. Raise it if plans are too granular.
- The auto-shard threshold of 500 lines works well for most codebases. Lower it for complex code, raise it for simple configuration files.

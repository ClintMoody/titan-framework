# TITAN

**The complete software development framework for building world-class products.**

One person, armed with TITAN, can build software that competes with teams of hundreds.

---

## What Is TITAN?

TITAN is a meta-prompting framework for AI-assisted development. It gives you a complete, battle-tested pipeline from first idea to shipped product — and handles everything in between, including problems nobody has solved before.

TITAN works with **Claude Code** and **OpenCode**. It manages your entire development lifecycle through structured commands, specialized AI agents, and proven workflows.

### Who Is It For?

You. The solo developer who wants to:

- **Build world-class software** without a team of 50
- **Ship fast** without cutting corners on quality
- **Handle any problem** — even novel ones you've never encountered
- **Make confident decisions** backed by systematic research and evidence
- **Learn as you build** — TITAN teaches through doing, not lecturing

Whether you've never written a line of code or you've shipped a hundred products, TITAN meets you where you are and takes you further than you thought possible.

---

## The Golden Path

TITAN's core workflow is 8 numbered steps. Follow them in order. It's that simple.

```
  ┌─────────────────────────────────────────────────────────────┐
  │                    THE GOLDEN PATH                          │
  │                                                             │
  │  01 INIT ──→ 02 VISION ──→ 03 EXPLORE ──→ 04 DESIGN         │
  │                                               │             │
  │  08 SHIP ←── 07 VERIFY ←── 06 BUILD ←── 05 PLAN             │
  │                  │                        │                 │
  │                  └────── repeat 05→07 ────┘                 │
  │                       for each phase                        │
  └─────────────────────────────────────────────────────────────┘
```

| Step | Command | What Happens |
|------|---------|-------------|
| **01** | `/titan:init` | Start your project. TITAN sets up everything. |
| **02** | `/titan:vision` | Define what you're building and why. AI personas interview you to extract a clear vision, requirements, architecture, and **phased roadmap** — a numbered list of every phase you'll build, in order, with goals and milestones. |
| **03** | `/titan:explore` | Research the unknown. Study prior art, evaluate technologies, map the problem space. |
| **04** | `/titan:design` | Design your UI/UX through conversation. See real HTML mockups in your browser. Iterate until perfect. |
| **05** | `/titan:plan` | Create a detailed execution plan for the **current phase** from your roadmap. Tasks, waves, acceptance criteria, boundaries. |
| **06** | `/titan:build` | Execute the plan. Parallel AI agents build while you watch (or help). Atomic commits keep history clean. |
| **07** | `/titan:verify` | Prove it works. Mandatory reconciliation + adversarial review. Nothing ships unverified. |
| **08** | `/titan:ship` | Release. Tag. Celebrate. Move to the next milestone. |

**Repeat steps 05-07** for each phase in your roadmap. That's the entire workflow.

### You Are Never Lost

TITAN always tells you exactly what to do next.

**Your roadmap is your map.** During step 02 (`/titan:vision`), TITAN interviews you and builds a phased roadmap — a numbered list of everything that needs to be built, broken into logical phases with clear goals. This roadmap lives in `.titan/ROADMAP.md` and is your project's table of contents.

**Every command ends with guidance.** After each command completes, TITAN shows you:
1. **The recommended next action** — the single best thing to do right now
2. **Other available options** — alternatives for when your situation doesn't match the default

**TITAN tracks your position.** The file `.titan/STATE.md` always knows which phase you're on, what step you're at, and what to do next. You never have to remember where you left off.

**If you're ever unsure, run one of these:**
- `/titan:progress` — Full dashboard showing every phase, your current position, and what's next
- `/titan:resume` — Restores your context and tells you exactly where to pick up
- `/titan:help` — Complete command reference with contextual guidance

---

## Power Tools

Beyond the Golden Path, TITAN gives you specialized tools for any situation:

### Novel Problem Solving
When you encounter something nobody has solved before:

| Command | What It Does |
|---------|-------------|
| `/titan:investigate` | Systematic analysis of unknown problems — research, hypothesize, evaluate |
| `/titan:experiment` | Try multiple approaches in isolation, measure results, pick the winner |
| `/titan:learn` | Deep-dive research on any technology, pattern, or concept |

### Quality & Security
| Command | What It Does |
|---------|-------------|
| `/titan:review` | On-demand adversarial code review |
| `/titan:test` | Generate tests, run TDD workflows |
| `/titan:audit` | Security + performance + accessibility + domain audit |
| `/titan:debug` | Scientific debugging with persistent hypothesis tracking |
| `/titan:refactor` | Safe refactoring with test preservation |

### Codebase & Project
| Command | What It Does |
|---------|-------------|
| `/titan:scan` | Deep codebase analysis with 4 parallel research agents |
| `/titan:quick` | Small task with full quality guarantees (no shortcuts) |

### Session Management
| Command | What It Does |
|---------|-------------|
| `/titan:resume` | Continue from where you left off with full context |
| `/titan:pause` | Save state and create a handoff document |
| `/titan:progress` | See your project status dashboard |
| `/titan:autopilot` | Let TITAN run phases automatically |
| `/titan:settings` | Configure model profiles, domain, preferences |
| `/titan:help` | Complete command reference |

**24 commands total.** 8 core + 10 power tools + 6 session management.

---

## 9 Specialized Agents

TITAN deploys AI agents — each in a fresh 200k-token context window — to handle specialized work:

| Agent | Role |
|-------|------|
| **Executor** | Builds features from plans. One task = one atomic commit. |
| **Verifier** | Adversarial reviewer. Hunts for bugs across 5+ dimensions. Must find issues. |
| **Researcher** | Analyzes codebases before planning. Maps patterns, conventions, concerns. |
| **Designer** | Generates browser-testable HTML/CSS mockups from design briefs. |
| **Investigator** | Solves novel problems. Generates hypotheses, evaluates approaches. |
| **Strategist** | Evaluates architecture decisions. Compares approaches at system level. |
| **Security** | Detects vulnerabilities. OWASP Top 10, supply chain, secrets, headers. |
| **Optimizer** | Finds performance bottlenecks. Recommends targeted improvements. |
| **Tester** | Generates tests. Discovers edge cases. Measures coverage. |

---

## Pluggable Domain Expertise

TITAN doesn't assume you're building a web app. Configure your domain and get specialized quality checks:

```yaml
# .titan/config.yaml
domain:
  primary: web    # web | mobile | desktop | audio | game | data | api | infrastructure
```

Each domain adds:
- **Verifier checks** specific to that domain (e.g., accessibility for web, real-time safety for audio)
- **Researcher focus areas** (e.g., bundle analysis for web, battery impact for mobile)
- **Quality gates** that must pass before shipping
- **Patterns and anti-patterns** for that domain

8 domains included out of the box. Create your own by adding a YAML file.

---

## Quality Philosophy

TITAN enforces quality at every level:

1. **Acceptance Criteria Before Code** — Every requirement has BDD Given/When/Then criteria defined before anyone writes a line of code.

2. **Mandatory Verification** — Every phase closes with proof. Task-by-task reconciliation. What was planned vs. what was built. No exceptions.

3. **Adversarial Review** — The Verifier agent assumes bugs exist and hunts for them. It must find at least one genuine issue. Rubber-stamping is not allowed.

4. **Atomic Git History** — One commit per task. `git bisect` finds any regression trivially.

5. **Knowledge Accumulation** — Every phase adds to `.titan/KNOWLEDGE.md`. Patterns that work, decisions made, lessons learned. This compounds over time.

6. **Domain-Specific Gates** — Your domain plugin defines what "quality" means for your kind of software.

---

## Installation

### Quick Install (Recommended)

```bash
# Install globally for Claude Code + OpenCode
bash install.sh --global

# Install for Claude Code only
bash install.sh --global --claude-only

# Install for a specific project
bash install.sh --project-dir /path/to/project
```

### What Gets Installed

- 24 command files → `.claude/commands/titan/` (or `.opencode/commands/titan/`)
- 9 agent definitions → `.claude/agents/` (or `.opencode/agents/`)
- Templates → `.claude/templates/titan/`
- Domain plugins → `.claude/templates/titan/domains/`
- Reference documents → `.claude/templates/titan/references/`

### Uninstall

```bash
bash uninstall.sh --global              # Remove commands and agents
bash uninstall.sh --global --purge      # Also remove .titan/ project data
```

---

## Project Structure

After `/titan:init`, your project gets:

```
your-project/
├── .titan/
│   ├── config.yaml         # Your configuration
│   ├── STATE.md            # Current position (the brain)
│   ├── PROJECT.md          # Vision and scope
│   ├── REQUIREMENTS.md     # Requirements with acceptance criteria
│   ├── ARCHITECTURE.md     # Technical design
│   ├── ROADMAP.md          # Phase breakdown
│   ├── KNOWLEDGE.md        # Accumulated learnings
│   ├── DECISIONS.md        # Decision log with rationale
│   ├── phases/             # Per-phase plans, summaries, evaluations
│   ├── investigations/     # Novel problem research
│   ├── experiments/        # Experiment records
│   └── ...
├── CLAUDE.md               # Project rules
└── mockups/                # Approved UI designs
```

---

## Origin

TITAN is a fork of the [FORGE framework](../framework-comparison/forge-framework/), which synthesized three leading AI development frameworks:

- **PAUL** — Mandatory reconciliation, acceptance-driven BDD, context brackets
- **GSD** — Thin orchestrator, fresh-context subagents, parallel execution
- **BMAD** — Persona-driven planning, progressive artifacts, adversarial review

TITAN takes FORGE's 9.1/10 foundation and makes it:
- **General-purpose** — Pluggable domains instead of audio-specific
- **Novel-problem-capable** — Investigate + experiment workflows
- **More powerful** — 9 agents instead of 4, dedicated security/performance/testing
- **Knowledge-accumulating** — Every project gets smarter over time
- **Beginner-friendly** — Guides without condescending

---

## Quick Start

```
/titan:init          # Start here
/titan:vision        # Define your product
/titan:explore       # Research unknowns
/titan:design        # Design the UI
/titan:plan          # Plan the first phase
/titan:build         # Build it
/titan:verify        # Prove it works
/titan:ship          # Ship it
```

That's it. You just built world-class software.

---

## License

MIT

---

*Built with conviction that one person can change the world — they just need the right tools.*

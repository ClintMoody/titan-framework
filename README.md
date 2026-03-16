<p align="center">
  <img src=".github/banner.svg" alt="TITAN — The Complete Software Development Framework" width="900"/>
</p>

<p align="center">
  <strong>One person, armed with TITAN, can build software that competes with teams of hundreds.</strong>
</p>

<p align="center">
  <a href="#installation"><img src="https://img.shields.io/badge/install-bash_install.sh-22C55E?style=flat-square&logo=gnu-bash&logoColor=white" alt="Install"/></a>
  <img src="https://img.shields.io/badge/license-MIT-334155?style=flat-square" alt="MIT License"/>
  <img src="https://img.shields.io/badge/commands-24-22C55E?style=flat-square" alt="24 Commands"/>
  <img src="https://img.shields.io/badge/agents-9-334155?style=flat-square" alt="9 Agents"/>
  <img src="https://img.shields.io/badge/domains-8-22C55E?style=flat-square" alt="8 Domains"/>
</p>

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

TITAN's core workflow is **8 numbered steps**. Follow them in order. It's that simple.

```
                    ╭──────────────────────────────────────────────────╮
                    │              T H E   G O L D E N   P A T H       │
                    ╰──────────────────────────────────────────────────╯

              01 INIT ──▸ 02 VISION ──▸ 03 EXPLORE ──▸ 04 DESIGN
                                                           │
              08 SHIP ◂── 07 VERIFY ◂── 06 BUILD ◂── 05 PLAN
                              │                        │
                              ╰──── repeat 05 → 07 ───╯
                                    for each phase
```

| Step | Command | What Happens |
|:----:|---------|-------------|
| `01` | `/titan:01-init` | Start your project. TITAN sets up everything. |
| `02` | `/titan:02-vision` | Define what you're building and why. AI personas interview you to extract a clear vision, requirements, architecture, and **phased roadmap**. |
| `03` | `/titan:03-explore` | Research the unknown. Study prior art, evaluate technologies, map the problem space. |
| `04` | `/titan:04-design` | Design your UI/UX through conversation. See real HTML mockups in your browser. |
| `05` | `/titan:05-plan` | Create a detailed execution plan for the **current phase** from your roadmap. |
| `06` | `/titan:06-build` | Execute the plan. Parallel AI agents build while you watch (or help). |
| `07` | `/titan:07-verify` | Prove it works. Mandatory reconciliation + adversarial review. Nothing ships unverified. |
| `08` | `/titan:08-ship` | Release. Tag. Celebrate. Move to the next milestone. |

> **Repeat steps 05–07** for each phase in your roadmap. That's the entire workflow.

### You Are Never Lost

TITAN always tells you exactly what to do next.

**Your roadmap is your map.** During step 02 (`/titan:02-vision`), TITAN interviews you and builds a phased roadmap — a numbered list of everything that needs to be built, broken into logical phases with clear goals. This roadmap lives in `.titan/ROADMAP.md` and is your project's table of contents.

**Every command ends with guidance.** After each command completes, TITAN shows you:
1. **The recommended next action** — the single best thing to do right now
2. **Other available options** — alternatives for when your situation doesn't match the default

**TITAN tracks your position.** The file `.titan/STATE.md` always knows which phase you're on, what step you're at, and what to do next. You never have to remember where you left off.

**If you're ever unsure, run one of these:**
- `/titan:progress` — Full dashboard showing every phase, your current position, and what's next
- `/titan:resume` — Restores your context and tells you exactly where to pick up
- `/titan:help` — Complete command reference with contextual guidance

<details>
<summary><strong>When to clear context</strong></summary>

<br/>

AI context windows fill up during long conversations. TITAN tells you when to clear context (`/clear`) so each step gets fresh, focused attention:

- **After `/titan:02-vision`** — Vision is conversation-heavy. Clear before planning.
- **Before `/titan:05-plan`** — The planner spawns a researcher agent that works best with clean context.
- **Before `/titan:06-build`** — Build agents are spawned fresh anyway, but a clean orchestrator helps.
- **Before `/titan:07-verify`** — Verification must be adversarial. Fresh context prevents bias from the build phase.

TITAN will remind you at these transitions. Your project state is always safe in `.titan/STATE.md` — clearing context loses nothing.

</details>

---

## Power Tools

Beyond the Golden Path, TITAN gives you specialized tools for any situation.

<table>
<tr>
<td width="50%" valign="top">

### Novel Problem Solving

| Command | What It Does |
|---------|-------------|
| `/titan:investigate` | Systematic analysis of unknown problems |
| `/titan:experiment` | Try approaches in isolation, pick the winner |
| `/titan:learn` | Deep-dive research on any concept |

### Codebase & Project

| Command | What It Does |
|---------|-------------|
| `/titan:scan` | Deep analysis with 4 parallel agents |
| `/titan:quick` | Small task, full quality guarantees |

</td>
<td width="50%" valign="top">

### Quality & Security

| Command | What It Does |
|---------|-------------|
| `/titan:review` | Adversarial code review |
| `/titan:test` | Generate tests, TDD workflows |
| `/titan:audit` | Security + perf + a11y audit |
| `/titan:debug` | Scientific debugging |
| `/titan:refactor` | Safe refactoring with test preservation |

### Session Management

| Command | What It Does |
|---------|-------------|
| `/titan:resume` | Continue from where you left off |
| `/titan:pause` | Save state and handoff document |
| `/titan:progress` | Project status dashboard |
| `/titan:autopilot` | Run phases automatically |
| `/titan:settings` | Configure preferences |
| `/titan:help` | Complete command reference |

</td>
</tr>
</table>

> **24 commands total** — 8 core + 10 power tools + 6 session management.

---

## 9 Specialized Agents

TITAN deploys AI agents — each in a fresh 200k-token context window — to handle specialized work.

<table>
<tr><td>

| Agent | Role |
|:------|:-----|
| **Executor** | Builds features from plans. One task = one atomic commit. |
| **Verifier** | Adversarial reviewer. Hunts for bugs across 5+ dimensions. |
| **Researcher** | Analyzes codebases before planning. Maps patterns and concerns. |
| **Designer** | Generates browser-testable HTML/CSS mockups from design briefs. |
| **Investigator** | Solves novel problems. Generates hypotheses, evaluates approaches. |
| **Strategist** | Evaluates architecture decisions at system level. |
| **Security** | Detects vulnerabilities. OWASP Top 10, supply chain, secrets. |
| **Optimizer** | Finds performance bottlenecks. Recommends improvements. |
| **Tester** | Generates tests. Discovers edge cases. Measures coverage. |

</td></tr>
</table>

---

## Pluggable Domain Expertise

TITAN doesn't assume you're building a web app. Configure your domain and get specialized quality checks.

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

<table>
<tr>
<td width="33%" valign="top">

**Acceptance Criteria Before Code**
Every requirement has BDD Given/When/Then criteria before anyone writes a line of code.

**Mandatory Verification**
Every phase closes with proof. Task-by-task reconciliation. No exceptions.

</td>
<td width="33%" valign="top">

**Adversarial Review**
The Verifier agent assumes bugs exist and hunts for them. It must find at least one genuine issue.

**Atomic Git History**
One commit per task. `git bisect` finds any regression trivially.

</td>
<td width="33%" valign="top">

**Knowledge Accumulation**
Every phase adds to `.titan/KNOWLEDGE.md`. Patterns, decisions, lessons. This compounds over time.

**Domain-Specific Gates**
Your domain plugin defines what "quality" means for your kind of software.

</td>
</tr>
</table>

---

## Installation

```bash
# Install globally for Claude Code + OpenCode
bash install.sh --global

# Install for Claude Code only
bash install.sh --global --claude-only

# Install for a specific project
bash install.sh --project-dir /path/to/project
```

<details>
<summary><strong>What gets installed</strong></summary>

<br/>

- 24 command files → `.claude/commands/titan/` (or `.opencode/commands/titan/`)
- 9 agent definitions → `.claude/agents/` (or `.opencode/agents/`)
- Templates → `.claude/templates/titan/`
- Domain plugins → `.claude/templates/titan/domains/`
- Reference documents → `.claude/templates/titan/references/`

</details>

<details>
<summary><strong>Uninstall</strong></summary>

<br/>

```bash
bash uninstall.sh --global              # Remove commands and agents
bash uninstall.sh --global --purge      # Also remove .titan/ project data
```

</details>

---

## Project Structure

After `/titan:01-init`, your project gets:

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

TITAN takes FORGE's 9.1/10 foundation and makes it **general-purpose**, **novel-problem-capable**, and **knowledge-accumulating** — with 9 agents, pluggable domains, and a workflow that guides without condescending.

---

## Quick Start

```
/titan:01-init          # Start here
/titan:02-vision        # Define your product
/titan:03-explore       # Research unknowns
/titan:04-design        # Design the UI
/titan:05-plan          # Plan the first phase
/titan:06-build         # Build it
/titan:07-verify        # Prove it works
/titan:08-ship          # Ship it
```

> That's it. You just built world-class software.

---

<p align="center">
  <sub>MIT License</sub>
</p>

<p align="center">
  <em>Built with conviction that one person can change the world — they just need the right tools.</em>
</p>

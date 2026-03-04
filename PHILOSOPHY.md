# TITAN Philosophy

> The principles that guide every design decision in TITAN.

---

## The Core Belief

**One person, armed with the right system, can build software that rivals anything built by the largest teams in the world.**

This isn't aspirational. It's architectural. TITAN is designed from the ground up to make this true.

---

## The Seven Principles

### 1. Simplicity Is Power

The Golden Path is 8 steps. You can learn it in 5 minutes. You can master it in a day.

Complexity is the enemy of execution. Every time we considered adding a feature, we asked: "Does this make the developer's life simpler?" If the answer was no — or even "it depends" — we didn't add it.

TITAN has 24 commands, but you only need 8 to build a complete product. The other 16 are power tools that appear when you need them, not before.

**Design rule:** If a workflow requires the developer to make more than 2 decisions before starting, it's too complex. Simplify.

### 2. Novel Problems Are Solvable

Most frameworks assume you know what you're building and how to build it. TITAN doesn't.

The hardest part of software development isn't writing code — it's figuring out what to build when nobody has built it before. TITAN gives you a systematic approach:

1. **Articulate** the problem precisely (what's unknown, what we know, what success looks like)
2. **Research** exhaustively (prior art, related problems, academic/industry approaches)
3. **Hypothesize** broadly (minimum 3 distinct approaches, never just one)
4. **Experiment** rigorously (isolated prototypes, measured outcomes)
5. **Evaluate** honestly (against criteria, not against hope)
6. **Decide** with evidence (document the choice and the reasoning)

This loop handles ANYTHING — from "how should I structure my database" to "nobody has ever combined these two technologies before."

**Design rule:** Every TITAN workflow must work even when the developer has never encountered the problem before.

### 3. Quality Is Mandatory, Not Optional

In TITAN, you cannot skip verification. This isn't a limitation — it's a superpower.

When you know that every phase will be reconciled against its plan, that every piece of code will face an adversarial reviewer who MUST find issues, that every acceptance criterion will be explicitly passed or failed — you build differently. You build with confidence.

The mandatory verification loop catches issues when they're cheap to fix, not when they're expensive to explain to users.

**Design rule:** No phase is complete without proof. "It probably works" is not proof.

### 4. Context Is The Scarcest Resource

AI context windows are large but finite. TITAN treats context like a fighter pilot treats fuel — always aware of how much remains, always planning for what's ahead.

**Context Brackets** adapt behavior automatically:
- **FRESH** (>70% remaining): Explore freely, consider multiple approaches
- **MODERATE** (40-70%): Focus on the best approach, execute efficiently
- **DEEP** (20-40%): Essential operations only, prepare to save state
- **CRITICAL** (<20%): Stop. Save everything. Create handoff.

**Fresh-context agents** get clean 200k-token windows. They never inherit the orchestrator's fatigue.

**Document sharding** breaks large files into focused chunks, saving 90% of tokens.

**Work unit sizing** targets 50% of context per plan, with 2-3 tasks maximum. This ensures quality never degrades because the AI "ran out of room."

**Design rule:** Every command must work within context constraints. If it requires more context than available, it must split the work, not degrade the quality.

### 5. Every Decision Gets A Receipt

In a complex project, the question "why did we do it this way?" comes up constantly. TITAN ensures the answer is always available.

- **DECISIONS.md** records every non-trivial decision with rationale
- **KNOWLEDGE.md** accumulates patterns, learnings, and insights
- **SUMMARY.md** (per phase) documents what was built vs. what was planned
- **INVESTIGATION.md** and **EXPERIMENT.md** document the research that led to choices

Six months from now, when you (or a new AI session) needs to understand why the authentication system uses JWTs instead of sessions, the answer is in DECISIONS.md — not buried in a forgotten conversation.

**Design rule:** If a decision requires more than 10 seconds of thought, it requires a record.

### 6. Domain Expertise Is Not One-Size-Fits-All

A web application and an audio plugin have completely different quality criteria. Checking for WCAG accessibility in a command-line tool is as useless as checking for buffer underruns in a React app.

TITAN uses pluggable domain plugins that customize:
- What the Verifier checks for
- What the Researcher focuses on
- What quality gates must pass
- What patterns to follow and avoid

8 domains ship with TITAN. Creating a new one is a single YAML file.

**Design rule:** Never hardcode domain assumptions. Always make expertise pluggable.

### 7. Speed Comes From Certainty

The biggest time waste in software development isn't slow typing — it's rework. Building the wrong thing. Building the right thing wrong. Discovering a fundamental flaw after weeks of work.

TITAN is fast because it eliminates rework:

- **Vision** ensures you're building the right thing before writing code
- **Explore** ensures you understand the problem space before designing solutions
- **Plan** ensures you have a clear path before starting work
- **Verify** ensures each phase is correct before building on top of it
- **Parallel agents** do the actual building efficiently

The developer who spends 2 hours planning and 4 hours building ships faster than the developer who spends 8 hours building and 4 hours fixing.

**Design rule:** Every "slow" step (vision, explore, plan, verify) exists to make the "fast" steps (build, ship) actually fast.

---

## Architectural Decisions

### Why 8 Core Steps (Not 5, Not 12)?

- Steps 01-02 (init, vision) are **setup** — you do them once per project
- Step 03 (explore) is **research** — you do it when facing unknowns
- Step 04 (design) is **design** — you do it when there's a UI
- Steps 05-07 (plan, build, verify) are **the execution loop** — you repeat this per phase
- Step 08 (ship) is **release** — you do it per milestone

This maps to how software actually gets built: understand → research → design → (plan → build → prove)* → ship.

Fewer steps would conflate distinct activities. More steps would add ceremony without value.

### Why 9 Agents (Not 3, Not 20)?

Each agent exists because its job requires specialized focus AND benefits from a fresh context window:

- **Executor** needs clean context to implement without the orchestrator's baggage
- **Verifier** needs adversarial distance — can't review code it helped plan
- **Researcher** needs to explore broadly without polluting planning context
- **Designer** needs visual/creative focus separate from technical implementation
- **Investigator** needs deep research focus for novel problems
- **Strategist** needs architectural perspective without implementation details
- **Security** needs paranoid focus that would slow down regular development
- **Optimizer** needs performance-specific analysis tools and mindset
- **Tester** needs to think about edge cases without implementation bias

Three agents would overload some with unrelated tasks. Twenty agents would create coordination overhead that costs more than it saves.

### Why Mandatory Verification?

Optional quality checks get skipped. Always. Under deadline pressure, "we'll review it later" becomes "we never reviewed it."

Making verification mandatory means:
1. Developers plan for it (it's step 7, not an afterthought)
2. Issues surface early (when fixes are cheap)
3. The project's history is clean (every phase has proof of completion)
4. Trust compounds (each verified phase makes the next one more confident)

The cost of mandatory verification is 5-10 minutes per phase. The cost of shipping unverified code is weeks of debugging, user complaints, and technical debt.

### Why Document Decisions?

Because AI sessions don't have long-term memory. Every conversation starts fresh. Without DECISIONS.md, the next session might make the opposite choice — and not even know it's contradicting a prior decision.

Decision records are also how solo developers simulate the institutional knowledge that teams build naturally through conversation.

### Why Pluggable Domains Instead of Generic Checks?

Generic checks produce two problems:
1. False positives: flagging irrelevant issues wastes time and erodes trust
2. False negatives: missing domain-specific issues gives false confidence

A web developer needs accessibility and SEO checks but not buffer management. An audio developer needs real-time safety and denormal protection but not responsive design. Pluggable domains give you exactly the checks you need — no more, no less.

---

## What TITAN Is Not

- **Not an IDE.** TITAN works inside Claude Code or OpenCode. It's the system, not the tool.
- **Not a template generator.** TITAN manages the full lifecycle, not just project scaffolding.
- **Not a replacement for thinking.** TITAN guides decisions but never makes them for you without consent.
- **Not a silver bullet.** Great software still requires care, taste, and persistence. TITAN just makes sure those qualities aren't wasted.
- **Not locked to Claude.** While optimized for Claude models, the architecture supports any LLM capable of tool use.

---

## The Vision

We believe the next generation of world-changing software will be built by individuals and tiny teams who leverage AI as a force multiplier. Not by replacing human judgment, but by augmenting it with:

- Systematic workflows that prevent the mistakes humans (and AI) naturally make
- Specialized agents that bring expert-level analysis to every phase
- Knowledge accumulation that makes every project smarter than the last
- Novel problem solving that turns "I don't know how" into "let's find out"

TITAN is the framework that makes this vision real.

---

*"The difference between a thing that might go wrong and a thing that cannot possibly go wrong is that when a thing that cannot possibly go wrong goes wrong, it usually turns out to be impossible to get at or repair." — Douglas Adams*

*TITAN makes things possible to get at and repair.*

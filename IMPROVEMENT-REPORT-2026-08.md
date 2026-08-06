# TITAN Improvement Report — August 2026

> Research only. No changes were made to the framework.
> This report uses plain language. Short sentences. One idea per sentence.
> Written after a full review of TITAN v2.3 and a wide research pass on
> GitHub, official Claude Code documentation, and the AI-development community.

---

## 1. Why This Report Exists

TITAN was built against the tools of early 2026. The world moved.
The systems TITAN borrowed from have changed. Claude Code itself has changed even more.
Many things TITAN builds by hand are now built into the platform.
This report lists what changed and what TITAN can do about it.

Each recommendation says three things:
- **What it is.** A short description.
- **Why it helps.** The problem it solves.
- **Where it comes from.** The source, so you can read more.

---

## 2. What Changed in the Outside World

### 2.1 GSD split into two projects

Your memory was correct. GSD is now a standalone harness — but only one half of it.

- The original author (TÂCHES) vanished in May 2026. His accounts are deleted.
  A crypto token tied to the project was publicly linked to a rug-pull.
  The original repos are archived.
- A community group called **Open GSD** now runs the project. It has two products:
  - **gsd-core** — still a prompt framework, like TITAN. It runs inside Claude Code,
    OpenCode, Cursor, Codex, and more. Active, v1.7.0.
  - **gsd-pi** — a full standalone application built on the Pi SDK.
    It has its own database, terminal UI, web dashboard, VS Code extension,
    and headless mode. Active, v1.12.0 (Aug 3, 2026).
- gsd-pi's key design change: a **database is the source of truth**, not markdown files.
  The markdown files are only views of the database.
- Sources: github.com/open-gsd/gsd-core · github.com/open-gsd/gsd-pi

### 2.2 BMAD moved to v6

- Expansion packs are gone. BMAD now uses **modules** with separate versions.
- All agents and workflows became **skills** (the Claude Code format).
- BMAD **merged three personas into one Developer agent**. Persona sprawl was walked back.
- Code review became **three parallel review layers** plus an "Edge Case Hunter."
- Review personas are now configured to **resist agreement** ("anti-consensus").
- BMAD added its own Ralph-style unattended loop (`bmad-loop`, July 2026).
- Source: github.com/bmad-code-org/BMAD-METHOD

### 2.3 PAUL grew a verification loop and an ecosystem

- PAUL v1.2+ scores each finished task as **PASS, GAP, or DRIFT**.
  GAP means incomplete. DRIFT means the agent did something else than planned.
  Three retries, then escalate.
- Before a retry, PAUL asks: is the fault in the **intent, the spec, or the code**?
  The fix then targets the right artifact.
- A companion tool (CARL) injects rules **just in time**, based on keywords in the prompt.
  Rules cost zero tokens until they are needed.
- Source: github.com/ChristopherKahler/paul

### 2.4 The Ralph loop went mainstream

- The "run the agent in a loop until done" technique is now an **official Anthropic
  plugin** (`ralph-wiggum`) in the Claude Code plugin marketplace.
- The community settled on hard rules for safe loops:
  - **Fresh context every iteration.** The reset is the feature.
  - **One task per iteration.** Never more.
  - **A completion promise.** The loop exits only when the agent outputs an exact
    phrase, and only when the claim is true.
  - **A maximum iteration count.** A hard stop, always.
  - **Backpressure.** Tests, linters, and builds steer the loop. Not prompts.
- Sources: github.com/ghuntley/how-to-ralph-wiggum · anthropics/claude-code (plugins/ralph-wiggum)

### 2.5 Claude Code now does natively what TITAN does by hand

This is the largest finding. Details are in Section 3.
Claude Code now has: skills, plugins with marketplaces, hooks, native checkpoints
with `/rewind`, exact context readout with `/context`, cost readout with `/cost`,
native git worktrees, subagent memory and isolation options, auto memory,
path-scoped rules, scheduled loops, and an Agent SDK.
Source: code.claude.com/docs

### 2.6 Other useful projects

- **spec-kit** (GitHub's own): spec-driven development with a "constitution" file,
  a clarify step, and a cross-check step that compares spec, plan, and tasks.
- **OpenSpec**: living specs plus per-change delta folders (ADDED / MODIFIED / REMOVED).
- **Kiro** (AWS): acceptance criteria in EARS format
  ("WHEN [condition] THE SYSTEM SHALL [behavior]").
- **Task Master**: scores task complexity 1-10 and expands only complex tasks.
  Validates task dependency graphs by machine.
- **claude-flow (now "ruflo")**: large claims, little independent proof. Skip it.

---

## 3. Group A — Use Built-In Platform Features (Highest Impact)

TITAN spends much of its prompt text telling the model to simulate features
that now exist as real, deterministic platform features.
Real features do not drift. Prompts do.

### A1. Ship TITAN as a Claude Code plugin

- **What:** Replace `install.sh` with a plugin. A plugin bundles commands, agents,
  skills, hooks, and settings in one package with a version number.
  Users install it with one command. Updates arrive automatically.
- **Why:** No more file copying. No more stale-version cleanup code
  (the installer already needed a fix for stale v1 commands). Marketplace visibility.
- **Note:** Keep the shell installer only for OpenCode support, if you keep OpenCode.
- **Source:** code.claude.com/docs/en/plugins

### A2. Convert commands to skills

- **What:** Skills are the successor to command markdown files. They add:
  auto-invocation when relevant, a switch to forbid auto-invocation, lazy loading,
  an option to run in a forked context, and an option to run in the background.
- **Why:** Only the name and description of a skill stay loaded. The body loads
  on demand. This saves context in every session. BMAD already made this move.
- **Source:** code.claude.com/docs/en/skills

### A3. Replace context brackets with real numbers

- **What:** TITAN asks the model to estimate its remaining context ("brackets").
  Models are bad at this. Claude Code now shows exact numbers via `/context`,
  and compacts automatically when the window fills.
- **Why:** Estimated brackets fail silently. Real numbers do not.
- **Keep:** The bracket *policy* (what to do at each fill level) is still good.
  Only the *measurement* should change.
- **Source:** code.claude.com/docs/en/context-window

### A4. Replace lock-file crash recovery with native checkpoints

- **What:** Claude Code snapshots state before every prompt and keeps 100 checkpoints.
  `/rewind` restores code, conversation, or both. Sessions can be resumed by ID.
- **Why:** Lock files have stale-lock problems. TITAN's build command spends ~40 lines
  handling them. Checkpoints remove that whole class of failure.
- **Keep:** The append-only progress log. It is still the right tool for
  *cross-session* memory. Checkpoints cover *in-session* recovery.
- **Source:** code.claude.com/docs/en/checkpointing

### A5. Replace prompted cost tracking with real cost data

- **What:** TITAN asks the model to write `metrics.json`. The model estimates costs.
  Claude Code now reports real cost via `/cost`, exports metrics via OpenTelemetry,
  and the Agent SDK returns exact per-model cost per query.
- **Why:** Estimated numbers made the budget ceiling decorative.
  Real numbers make it enforceable.
- **Keep:** The budget ceiling and the warn/pause/halt policy. Feed them real data.
- **Source:** code.claude.com/docs/en/monitoring-usage

### A6. Rebuild the autonomous loop on supported rails

- **What:** `titan-loop.sh` calls `claude --print` in a bash while-loop.
  Three supported options now exist:
  1. The official **ralph-wiggum plugin** (a stop-hook loop with a completion
     promise and an iteration cap).
  2. **`/loop`** for interval-based runs inside a session.
  3. The **Agent SDK** for a real programmatic harness (the gsd-pi road — a larger step).
- **Why:** The bash loop cannot see session state, cannot resume cleanly, and
  re-implements safety rails the plugin already has.
- **Source:** anthropics/claude-code plugins · code.claude.com/docs/en/agent-sdk/overview

### A7. Use native worktrees

- **What:** Claude Code creates and cleans up git worktrees itself
  (`--worktree`, and `isolation: worktree` on subagents).
- **Why:** TITAN's worktree config is prompt-managed. Native worktrees are automatic,
  cross-edit-protected, and self-cleaning.
- **New pattern to adopt:** one worktree per task. Merge only after verification passes.
  A failed task is discarded by deleting its worktree. No rollback logic needed.
- **Source:** code.claude.com/docs/en/worktrees

### A8. Use modern subagent options

- **What:** Subagent files now support: `model`, `effort` (reasoning depth),
  `memory: true` (the agent keeps its own persistent notes), `background`,
  and worktree isolation.
- **Why:** The verifier and researcher could remember project patterns across
  sessions with one line of configuration. Effort levels give finer cost control
  than model choice alone.
- **Source:** code.claude.com/docs/en/sub-agents

### A9. Split state between auto memory and .titan files

- **What:** Claude Code now writes its own memory file per project and loads it
  at session start. Rules files can be scoped to file paths, loading only when
  matching files are touched.
- **Why:** Part of STATE.md and KNOWLEDGE.md duplicates what auto memory now does.
  Domain rules loaded only when relevant files are open would save context.
- **Caution:** `.titan/` files are portable across tools (OpenCode). Auto memory
  is Claude-Code-only. Keep `.titan/` as the source of truth. Treat auto memory
  as an accelerator, not a replacement. This is the same "which store is the truth"
  decision GSD faced. Decide it deliberately.
- **Source:** code.claude.com/docs/en/memory

---

## 4. Group B — Enforce Rules With Hooks, Not Prompts

TITAN's rules live in prompts. The model can ignore prompts. It sometimes does.
Hooks are shell commands that run at fixed events. They cannot be ignored.
This group is the single largest reliability upgrade available.

### B1. Run verification commands from a hook

- **What:** Move `verification.commands` (npm test, cargo check) into a
  PostToolUse hook. The hook runs after every file edit. A failing exit code
  blocks progress and feeds the error back to the model.
- **Why:** Today the executor is *asked* to run the commands. A hook *makes* them run.
- **Source:** code.claude.com/docs/en/hooks-guide

### B2. Enforce TDD strict mode with a hook (tdd-guard pattern)

- **What:** A PreToolUse hook inspects every write. It blocks code written
  without a failing test, and blocks code that exceeds what the test requires.
  The open-source `tdd-guard` project does exactly this.
- **Why:** TITAN's "Iron Law" is currently a plea in the executor prompt.
  A hook turns it into a law.
- **Source:** github.com/nizos/tdd-guard

### B3. Enforce task file boundaries with a hook

- **What:** The plan lists which files a task may touch. A PreToolUse hook can
  reject edits outside that list.
- **Why:** Boundary violations are currently caught late, by the verifier.
  A hook catches them at the moment of the edit.

### B4. Re-inject rules after compaction

- **What:** When a long session is compressed, safety and quality rules are often
  lost from the summary. Research calls this "governance decay." A SessionStart /
  post-compaction hook can re-load the constitution and domain gates every time.
- **Why:** This is a documented failure mode of exactly the long autonomous runs
  TITAN v2.3 added. Cheap fix, real risk.
- **Source:** arxiv.org/pdf/2606.22528 · anthropic.com/engineering/effective-context-engineering-for-ai-agents

---

## 5. Group C — Verification Upgrades

### C1. Retire the "must find at least one issue" rule

- **What:** TITAN forces each review stage to find ≥1 issue. Your own recent commit
  (`fix(agents): stop verifier/researcher hallucinating fabricated findings`)
  shows the cost: when there is nothing to find, the rule manufactures findings.
- **Replace with:** (a) a truth checklist derived from the spec (see C2),
  (b) an evidence requirement — every finding must cite file and line,
  (c) a jury (see C3). "No confirmed issues" becomes a legal verdict.
- **Why:** The rule's goal was to prevent rubber-stamping. The replacements
  prevent rubber-stamping without inventing bugs.

### C2. Split the rubric: tests decide correctness, judges decide quality

- **What:** Never ask the LLM reviewer a question a test could answer.
  Deterministic checks (tests, type checks, linters) decide *correct or not*.
  The LLM judge is limited to what tests cannot measure: readability,
  spec fidelity, security posture, design fit.
- **Why:** This is the 2026 consensus for LLM-as-judge systems. It removes the
  judge's least reliable work and keeps its most valuable work.
- **Source:** deepeval.com/blog/llm-as-a-judge · Anthropic guidance (paraphrased)

### C3. Use a small jury with disagreeing personas

- **What:** For important reviews, spawn 3 judge subagents with different rubrics
  and no shared context. Take the majority verdict. Configure the personas to
  resist agreement (BMAD's "anti-consensus" pattern). Require each verdict in a
  fixed format: reasoning first, then the verdict.
- **Why:** Juries measurably cut single-judge bias. Cost is 3x on the review step
  only — small next to the cost of a bad merge.
- **Source:** BMAD v6.10 · deepeval.com/blog/llm-as-a-judge

### C4. Adopt PASS / GAP / DRIFT scoring with failure routing

- **What:** After each task, score the result: PASS (matches plan), GAP (incomplete),
  or DRIFT (did something other than planned). Before any retry, classify the
  fault: intent, spec, or code. Fix the artifact at fault, not always the code.
- **Why:** TITAN retries by re-prompting the executor. When the *spec* was wrong,
  that loops forever. PAUL's routing breaks the loop at the source.
- **Source:** github.com/ChristopherKahler/paul (v1.2 release notes)

### C5. Re-verify old features on a schedule (regression manifest)

- **What:** The feature manifest marks features passing/failing. Agents sometimes
  mark features passing that are not. Each verify cycle, re-check a sample of
  previously-passing features end to end.
- **Why:** Anthropic's own long-running-agent guidance warns that false "done"
  marks compound over overnight runs. TITAN's loop trusts the manifest completely.
- **Source:** anthropic.com/engineering/effective-harnesses-for-long-running-agents (paraphrased)

### C6. Add a "break the tests" check

- **What:** During verification, deliberately change one behavior in the
  implementation and confirm the test suite fails. Then revert.
- **Why:** It measures whether the tests can catch anything at all.
  A suite that cannot fail is decoration.

---

## 6. Group D — Planning and Spec Upgrades

### D1. Add a constitution file

- **What:** A short file of non-negotiable project rules, written at init/vision.
  Every later step starts with an explicit "constitution check."
  Re-inject it after compaction (see B4).
- **Why:** TITAN's principles live in many long documents. A constitution is one
  small file the model can actually hold in every context.
- **Source:** github.com/github/spec-kit

### D2. Add a clarify gate before planning

- **What:** After vision/explore, a pass marks every vague requirement with
  `[NEEDS CLARIFICATION]`. Planning is blocked until each marker is resolved.
- **Why:** Today ambiguity is discovered mid-build, as NEEDS_CONTEXT escalations.
  Finding it before planning is far cheaper.
- **Source:** github.com/github/spec-kit

### D3. Add an analyze gate: verify the plan, not just the code

- **What:** A read-only pass compares spec ↔ plan ↔ tasks. It reports coverage
  gaps, contradictions, and orphan tasks before the build starts.
- **Why:** TITAN verifies code against plan. Nothing verifies plan against spec.
- **Source:** github.com/github/spec-kit (/speckit.analyze)

### D4. Add a converge command for stale projects

- **What:** A pass that re-grounds all artifacts against the actual codebase and
  emits the remaining delta as new work.
- **Why:** TITAN's docs drift when a human codes outside the framework, or when a
  project sleeps for months. This is the recovery tool for that.
- **Source:** github.com/github/spec-kit (/speckit.converge)

### D5. Use EARS format for acceptance criteria

- **What:** "WHEN [condition] THE SYSTEM SHALL [behavior]." One sentence per
  requirement. Mechanically testable.
- **Why:** It maps one-to-one onto tests, which strengthens goal-backward
  verification. Keep BDD (Given/When/Then) where flows matter; EARS suits
  system-level rules better.
- **Source:** kiro.dev/docs/specs/feature-specs

### D6. Keep living specs, fold deltas in on completion

- **What:** TITAN v2.2 already frames brownfield tasks as ADDED/MODIFIED/REMOVED
  deltas. OpenSpec completes the idea: a permanent `specs/` tree holds current
  truth; each change folder holds deltas; on ship, deltas fold into the specs
  and the change folder is archived.
- **Why:** It gives the project durable cross-phase memory. Specs stop rotting
  in per-phase folders.
- **Source:** github.com/Fission-AI/OpenSpec

### D7. Score task complexity; expand only what needs it

- **What:** Score each planned task 1-10 with a cheap model. Expand only
  high-score tasks into subtasks. Validate the dependency graph by machine
  (no cycles, no dangling references). Compute "next task" from the graph.
- **Why:** TITAN v2.3's adaptive planning depth works at phase level. This works
  at task level, and it makes the loop's "pick next task" step deterministic.
- **Source:** github.com/eyaltoledano/claude-task-master

### D8. Compile a phase-context cache

- **What:** Before building a phase, compile everything the executors need
  (relevant spec parts, architecture rules, conventions) into one cached file.
  Executors read the cache, not the original documents.
- **Why:** Each executor currently re-reads PLAN, CLAUDE.md, domain YAML, and
  architecture summaries. One compiled file is cheaper and drifts less.
- **Source:** BMAD v6 changelog

### D9. Separate scratch artifacts from permanent ones

- **What:** Put planning scratch in an ephemeral folder. Promote only reconciled
  documents to permanent status. Archive the scratch on ship.
- **Why:** Stale intermediate documents pollute future context.
- **Source:** BMAD v6 changelog

---

## 7. Group E — Autonomous Loop Upgrades

### E1. Adopt the completion promise and iteration cap

- **What:** The loop exits only when the agent outputs an exact completion phrase,
  and only when the phrase's conditions are verifiably true. A hard maximum
  iteration count always applies.
- **Why:** TITAN's loop exits on manifest state, which agents mis-mark (see C5).
  The pair of gates is the community-hardened standard.
- **Source:** anthropics/claude-code (plugins/ralph-wiggum)

### E2. Split the loop into plan mode and build mode

- **What:** One prompt does only gap analysis and plan rewriting. Another prompt
  does exactly one task, tests it, commits, and updates the plan. Every iteration
  loads the identical small file set. Fresh context every iteration.
- **Why:** TITAN's loop mixes planning and building in one session prompt.
  Separation keeps each iteration inside the model's reliable zone.
- **Source:** github.com/ghuntley/how-to-ralph-wiggum

### E3. Add the "search before you claim it's missing" guardrail

- **What:** Before implementing anything, the loop agent must search the codebase
  for an existing implementation.
- **Why:** Duplicate implementation is the classic loop failure. One guardrail
  line prevents most of it.
- **Source:** github.com/ghuntley/how-to-ralph-wiggum

### E4. Route models with a ceiling, and escalate on failure

- **What:** Two rules from gsd-pi's routing: (a) the user's configured model is a
  ceiling — routing may only downgrade, never upgrade past it; (b) a failed task
  retries one tier up.
- **Why:** TITAN routes by task class only. Escalate-on-failure converts wasted
  retries into stronger retries. Tie-breaks go to the cheaper model,
  deterministically.
- **Source:** open-gsd/gsd-pi docs (dynamic-model-routing.md)

### E5. Pass handoff anchors between phases

- **What:** At each phase boundary, write a small structured file: intent,
  decisions made, blockers, next steps. The next phase reads the anchor instead
  of re-reading full artifacts.
- **Why:** It cuts the cost of TITAN's self-chaining autopilot and makes handoffs
  uniform.
- **Source:** open-gsd/gsd-pi docs (token-optimization.md)

### E6. Detect ping-pong loops, not just repeats

- **What:** gsd-pi's stuck detection watches a sliding window of dispatches and
  catches A→B→A→B cycles, then runs one deep-diagnostic retry, then stops.
  It also uses timeout tiers: soft (tell the agent to wrap up), idle (intervene),
  hard (recover).
- **Why:** TITAN's stuck taxonomy catches same-task repeats and circular fixes
  within a task. Cross-task ping-pong slips through.
- **Source:** open-gsd/gsd-pi docs (auto-mode.md)

### E7. Route unattended questions to a human channel

- **What:** In walk-away mode, decision points go to Slack/Discord/Telegram.
  The human answers with a reaction or a reply. The loop continues.
- **Why:** Today a BLOCKED task ends the walk-away run. A remote question turns
  many full stops into thirty-second pauses.
- **Source:** open-gsd/gsd-pi docs (remote-questions.md)

### E8. Ship through pull requests

- **What:** The ship step opens a PR. The verification transcript and the
  goal-backward checklist attach to the PR as the review artifact.
  Agents never merge; the human (or CI) merges.
- **Why:** The PR is the natural safety envelope, the natural audit record, and
  the natural team hand-off. This also opens the road to team use.

---

## 8. Group F — Structural Questions

### F1. The big fork: prompt framework, harness, or both

GSD faced TITAN's exact situation and chose **both**:
a prompt framework (gsd-core) and a standalone harness (gsd-pi), with git as the
bridge between them. TITAN has three options:

1. **Stay a prompt framework**, rebuilt on skills + plugin + hooks (Groups A-B).
   Least work. Keeps OpenCode support. Loses headless depth.
2. **Build a harness on the Agent SDK.** Real crash recovery, real cost data,
   programmatic orchestration, CI use. Most work. A different product.
3. **Both, sharing `.titan/` state.** The GSD road. Most reach, most maintenance.

Recommendation: do option 1 now. It is mostly deletion, not construction.
Re-evaluate option 2 after the platform's agent-teams feature matures.
Do not do option 3 alone.

### F2. Audit the nine agents

BMAD walked its persona count back. Anthropic's multi-agent research found token
budget explains ~80% of outcome quality; agent count explains little.
Two checks, not a rewrite:
- Does any agent exist that is really a *rubric*? (Security, Optimizer, and Tester
  overlap Verifier. A jury persona may serve better than a standing agent.)
- Does the orchestrator ever ingest bulk agent output? It should receive only
  compressed verdicts. TITAN's output-discipline rule covers executors;
  extend it to every agent.
Give every dispatch an explicit effort budget. Vague delegation is the top
documented multi-agent failure mode.

### F3. Watch agent teams

Claude Code's experimental agent-teams feature lets agents message each other,
not only report to a parent. A builder↔verifier conversation would strengthen
adversarial review. It is experimental; watch it, adopt later.

### F4. Progressive disclosure for domain plugins

Keep a one-line index of all domains resident. Load a domain's full YAML only
when the domain matches the task. Skills give this behavior nearly for free
after A2.

### F5. Small housekeeping notes

- BMAD renamed `.bmad` to `_bmad` because dot-folders are hidden from many
  indexers and context tools. Consider the same trade-off for `.titan`.
- Claude Code model names in TITAN's config templates are outdated
  (claude-opus-4 era). The current line is Opus 5 / Sonnet 5 / Haiku 4.5,
  plus effort levels. Config should name tiers, not hard-coded model IDs.
- A visible board file (task cards with todo/doing/review/done states) gives
  the user live orchestration state during builds. The progress log almost
  does this; a small format change makes it human-watchable.

---

## 9. Priority List

Ordered by value against effort. "Low effort" means prompt/config edits only.

| # | Recommendation | Effort | Value |
|---|----------------|--------|-------|
| 1 | B1-B2: Hooks for verification and TDD enforcement | Low | Highest — rules stop being optional |
| 2 | A1-A2: Ship as plugin; commands become skills | Medium | Highest — distribution + context savings |
| 3 | C1: Retire "must find one issue"; add evidence + checklist | Low | High — kills fabricated findings |
| 4 | E1-E3: Completion promise, iteration cap, plan/build split, dedupe guardrail | Low | High — safe walk-away runs |
| 5 | A3-A5: Real context, checkpoint recovery, real cost data | Low | High — deletes fragile subsystems |
| 6 | D1-D3: Constitution, clarify gate, analyze gate | Low | High — catches errors before build |
| 7 | C2-C4: Test/judge split, jury, PASS/GAP/DRIFT routing | Medium | High — verification depth |
| 8 | B4: Re-inject rules after compaction | Low | Medium — insurance for long runs |
| 9 | A7 + worktree-per-task merge gate | Medium | Medium — clean rollback for free |
| 10 | D6-D8: Living specs, complexity scoring, context cache | Medium | Medium — durability + cost |
| 11 | E4-E7: Routing escalation, anchors, ping-pong detection, remote questions | Medium | Medium — loop maturity |
| 12 | F1 option 2 (Agent SDK harness) | High | Later — strategic, not urgent |

---

## 10. What We Checked and Do Not Recommend

- **claude-flow / ruflo.** Large marketing claims (neural routing, SWE-bench
  scores). No independent verification found. The one durable idea — visible
  orchestration state — appears above as F5.
- **Copying gsd-pi's database-as-truth design into a prompt framework.**
  It only pays off with a real runtime. If TITAN goes the harness road (F1
  option 2), revisit.
- **More agents.** Evidence points the other way (F2).

---

## 11. Confidence Notes

- All GSD, BMAD, PAUL, spec-kit, OpenSpec, Task Master, and tdd-guard findings
  were read from their public repos or docs. High confidence.
- Some Anthropic engineering blog pages and ghuntley.com blocked direct fetching.
  Those findings are corroborated across several secondary sources but are
  paraphrased, not quoted. Medium-high confidence.
- Agent-teams details come partly from secondary guides. Verify against official
  docs before building on them.
- All third-party star counts and benchmark claims are reported as claims.

---

# Addendum — RLM and Dagu (Requested Follow-Up)

> Added the same day, after the owner confirmed the prompt-based direction
> and asked about two specific projects: brainqub3/RLM and Dagu.
> Verdict up front: **steal from both.** RLM gives TITAN a new power tool.
> Dagu gives TITAN a better skeleton for the autonomous loop.

---

## 12. RLM — Recursive Language Models (brainqub3/RLM)

### 12.1 What it is

- RLM is a technique from MIT CSAIL (Zhang, Kraska, Khattab, late 2025).
  The idea: do not put a large input into the context window.
  Put it in a variable instead. The model inspects the variable with code —
  peek, grep, slice, chunk. It sends the pieces to cheap sub-models.
  Code does the counting. Sub-models do the judging.
- The reported results are strong. On a benchmark the base model could not
  run at all (6-11 million token inputs), RLM scored 91%. On a pairwise
  reasoning test, the base model scored near zero; RLM scored 58.
  Caution: these numbers come from secondary coverage. The paper page
  blocked our fetcher.
- The brainqub3 repo is small and honest about it. It is a Claude Code
  **skill plus one Python script**, MIT licensed, marked "not for production."
  That is good news for TITAN. It is the same kind of artifact TITAN is
  made of. The patterns port directly, and the license permits it.
- Sources: github.com/brainqub3/RLM · arxiv.org/abs/2512.24601

### 12.2 What is genuinely new for TITAN

TITAN already has subagents, grep, and fresh context windows.
RLM adds four things those do not give:

1. **Provable coverage.** A subagent is conversational. It can skip items
   silently. RLM loops over chunks *in code*. Every chunk is visited.
   The count is checked with arithmetic before the answer is given.
2. **The never-read rule.** The orchestrator sees only metadata about the
   corpus: size, line count, a short preview. The full text never enters
   any context window. Reads are decided from metadata, then targeted.
3. **The semantics/bookkeeping split.** Python counts, sorts, and deduplicates.
   The model only judges. This removes a whole class of model arithmetic errors.
4. **Replayable runs.** Every step is saved as a re-runnable script with logs.
   A crashed run resumes from the last finished chunk.

### 12.3 Recommendations

- **R1. Port the skill as a power tool (`/titan:rlm`).**
  Vendor the REPL script into `scripts/`. Add a command that encodes the
  workflow: init → probe → chunk → fan out → aggregate → final answer.
  Keep the key safety mechanics: leaf calls run headless with **no tools**
  (`claude -p --allowedTools ""`), default to Haiku, truncate stdout,
  return errors as marker strings. Low effort. MIT license permits reuse
  with attribution.
- **R2. Add the never-read rule to researcher and investigator.**
  Prompt-only change. When input material is large (about 50K characters
  or more), forbid reading it whole. Require probing first: line counts,
  grep counts, previews. Then read targeted slices only.
  Add "read the whole corpus into context" to the anti-patterns file.
- **R3. Document the map-reduce pattern as a core doc.**
  For "touch every item" work — classify every finding, check every file
  against a checklist — the orchestrator should write a small script that
  batches items into tool-less Haiku calls and accumulates results in files.
  Batch fat: 50-100 items per call, not one call per item.
- **R4. Cap recursion at depth 1, as a hard rule.**
  Field reports on depth 2 are bad: cost explosions (one example: 2.5M
  tokens for one query), format collapse, and error amplification.
  A corpus worker must never spawn its own corpus workers.
- **R5. Add a routing rule for when to use it.**
  Use RLM when the corpus is large AND the task must touch every item
  (aggregate, classify, compare pairs, summarize everything).
  Do not use it to find one thing. Grep and a subagent are cheaper for that.
  RLM is a specialized tool, not a general upgrade.

---

## 13. Dagu — A Real Skeleton for the Autonomous Loop

### 13.1 What it is

- Dagu is a workflow engine: one Go binary, no database required.
  You define workflows as steps in a YAML file. It runs them on schedules,
  retries them, and shows them in a web dashboard.
- It is very active. Version 2.12.0 was released the day of this research.
  The repo moved from dagu-org to dagucloud. License is GPL-3.0.
- The important 2026 change: Dagu now targets AI agents as a first-class
  use case. Its tagline is "Run AI agents like production jobs."
  It has a built-in **harness step** that runs Claude Code headless,
  with timeout, output capture, JSON schema validation of the output,
  fallback providers, and approval gates.
- Sources: github.com/dagucloud/dagu · github.com/dagucloud/docs

### 13.2 What Dagu replaces, and what it does not

`titan-loop.sh` is roughly 200 lines of bash scaffolding around the real
logic. Dagu replaces the scaffolding. It does not replace the logic.

What moves to Dagu YAML:
- The while-loop → a `repeat_policy` (repeat until zero failing features,
  with an iteration limit and a cooldown interval).
- The Claude call → a harness step with a real timeout. Today a hung
  session hangs the loop forever. Dagu kills it at the deadline.
- The environment smoke test → a precondition.
- Escalation → a failure handler that writes the report and sends mail
  or a notification, with logs attached.
- Flaky-test retries → a retry policy (TITAN has no transient-retry today).
- Overnight runs → cron scheduling with overlap protection
  (`max_active_runs: 1` stops two loops running at once).
- Pause/stop/resume → the REST API.
- Session logs and progress → per-step logs, run history, and the web
  dashboard. This also delivers the "visible orchestration state" idea (F5)
  without building anything.
- Loop counters (thrash counts, budget totals) → Dagu's persistent state
  store, which survives across runs and is version-checked.

What stays in TITAN scripts and prompts:
- Health rules (thrash, stall, regression detection) — a small script step.
- Feature selection and the manifest format.
- All prompts, and the Ralph safety rails from Section 7 (E1-E3).
- Budget tracking. Dagu does not capture token costs from the harness.
  A small step must parse Claude's JSON output and accumulate the numbers.

### 13.3 The shape of the loop

Two YAML files. A parent and a child.

- **Parent (`titan-loop.yaml`):** one step that runs the child workflow,
  repeating until the manifest shows zero failing features, with a hard
  iteration limit. A final health gate decides pass or escalate.
  A failure handler writes the escalation report.
- **Child (`titan-session.yaml`):** orient → build (Claude harness step,
  with timeout) → verify (E2E script, one retry allowed) → checkpoint
  (git commit) → health check. The health script must separate two cases:
  "feature failed, keep looping" (normal) and "loop is unhealthy, stop"
  (exit with error, which triggers escalation).

### 13.4 Cautions

- **Pin the version.** Dagu is young in this role. The harness feature is
  weeks old. The project has renamed twice and changed YAML style between
  v1 (camelCase) and v2 (snake_case). Old blog posts — and model memory —
  show the old syntax.
- **No independent field reports yet.** We found no third-party accounts
  of running Claude Code under Dagu. TITAN would be an early adopter.
- **Keep outputs small.** Step outputs and state values cap near 1 MB.
  Pass file paths between steps, never transcripts.
- **License is fine for use, not for bundling.** GPL-3.0 allows TITAN to
  *use* Dagu as an external tool. Do not ship the binary inside TITAN.
  Document "install Dagu" as an optional dependency instead.
- **Skip controller DAGs for now.** Dagu also has an LLM-driven mode that
  picks the next step dynamically. Its own docs say: if you can draw the
  graph, draw the graph. TITAN's graph is drawable.
- **Headless auth.** Server/cron runs may need an API key rather than
  subscription login. That changes the cost model. Check before committing
  to overnight cron runs.

### 13.5 How the pieces fit together

The three loop ideas in this report stack cleanly:

- **Dagu** is the outer skeleton. Deterministic steps, timeouts, retries,
  schedule, dashboard, escalation.
- **Ralph rails** (Section 7) live inside each session: one task per
  iteration, fresh context, completion promise, search-before-implement.
- **RLM** is a power tool a session reaches for when a task must touch
  every item of something large.

None of this conflicts with the prompt-based decision. Dagu and the RLM
script are external tools the prompts call. The intelligence stays in
markdown.

---

## 14. Updated Priority List

The addendum items slot into the existing list like this:

| # | Recommendation | Effort | Value |
|---|----------------|--------|-------|
| — | Items 1-3 from Section 9 unchanged | | |
| 4a | R2, R4, R5: Never-read rule, depth cap, routing rule | Low | High — prompt-only, immediate |
| 4b | E1-E3 + Dagu skeleton (13.2-13.3) | Medium | High — replaces titan-loop.sh wholesale |
| — | Items 5-8 from Section 9 unchanged | | |
| 9a | R1, R3: Port /titan:rlm and the map-reduce core doc | Medium | Medium — new capability, clear boundaries |
| — | Remaining items unchanged | | |

---

## 15. Addendum Confidence Notes

- brainqub3/RLM findings come from reading the repo's README, skill file,
  and script source directly. High confidence.
- RLM paper benchmark numbers come from secondary coverage only. The arXiv
  page and the author's blog blocked our fetcher. Medium confidence.
- The depth-2 failure reports come from search summaries of a third-party
  study. Directionally credible, unverified. Medium-low confidence.
- Dagu capabilities were verified from the docs source repository, not the
  rendered docs site (which blocked our fetcher). High confidence on
  features; the exact behavior of `repeat_policy` at its iteration limit
  is unconfirmed — test it before relying on it.
- Dagu token/cost capture: not documented; assumed absent.

---

*Research performed 2026-08-06 on branch `claude/titan-architecture-research-a0kwmg`.
Six parallel research passes: GSD lineage; BMAD/PAUL/Ralph; Claude Code platform;
wider ecosystem; RLM; Dagu. No framework files were changed.*

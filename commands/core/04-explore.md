---
name: titan:04-explore
description: Deep research and discovery — study prior art, evaluate technologies, map unknowns
---

# /titan:04-explore — Exploration & Research

> Run this command when there are unknowns in your project. Use it before planning a phase that involves unfamiliar territory, novel problems, or technology choices that need evaluation. This is TITAN's systematic approach to "figuring things out."

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` first)
- `.titan/PROJECT.md` exists (run `/titan:02-vision` first, or at minimum have a clear project direction)
- Recommended: `.titan/ROADMAP.md` exists so exploration can target specific phases

If prerequisites are not met, inform the user and suggest the correct command.

## When to Use This Command

- You are about to start a phase that involves technology you have not used before
- The architecture has components whose implementation approach is unclear
- There are multiple viable approaches and you need to compare them
- The problem domain has constraints you do not fully understand
- You need to study prior art or existing solutions before designing your own
- A previous `/titan:08-verify` flagged unknowns or knowledge gaps

## Process

### Step 1: Display Banner

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — EXPLORATION & RESEARCH                          ║
╚══════════════════════════════════════════════════════════════╝

  Systematic research to eliminate unknowns before building.
```

### Step 2: Determine Exploration Scope

Ask the user:

```
What do you want to explore?

  1. Specific phase     — Research for an upcoming phase
  2. Technology choice  — Evaluate and compare technologies
  3. Problem domain     — Understand a problem space deeply
  4. Architecture       — Evaluate architectural approaches
  5. Whole project      — Broad research sweep across all unknowns
  6. Custom topic       — Something specific not listed above

Enter number or describe what you need to research:
```

Wait for the user's response. Based on their answer, determine:
- **Exploration target:** What specific topic(s) to research
- **Exploration depth:** Broad survey vs. deep dive
- **Output location:** Phase-specific (`.titan/phases/NN/EXPLORATION.md`) or project-wide (`.titan/EXPLORATION.md`)

If the user selects "1. Specific phase", ask which phase from the ROADMAP.md. Read the roadmap first to present valid options.

### Step 3: Identify Research Questions

Based on the scope, work with the user to formulate specific research questions. This is a brief conversation (2-4 exchanges), not a full interview.

```
─── Research Scoping ────────────────────────────────────────

  Based on [scope], let's define what we need to find out.
```

Guide the conversation to produce a list of 3-7 concrete research questions. Examples:
- "What is the best approach for [specific technical challenge]?"
- "What are the trade-offs between [option A] and [option B]?"
- "How have others solved [specific problem]?"
- "What are the performance characteristics of [technology]?"
- "What are the common pitfalls when implementing [pattern]?"

For each question the user raises, probe for clarity:
- "What would a good answer to that question look like?"
- "Are there specific constraints that should influence the answer?"
- "What is the consequence of getting this wrong?"

Confirm the research questions before proceeding:

```
  Research Questions:
  ─────────────────────────────────────────────────
  Q1: [question]
  Q2: [question]
  Q3: [question]
  ...
  ─────────────────────────────────────────────────

  Does this capture what you need to research?
  Add/modify questions or say "go" to start research.
```

### Step 4: Execute Research

For each research question, conduct systematic research using available tools. The approach depends on the question type:

**For technology evaluation questions:**
1. Search the web for current benchmarks, comparisons, and community sentiment
2. Check official documentation for the technologies in question
3. Look for known limitations, breaking changes, and maturity indicators
4. Assess ecosystem health: community size, package availability, maintenance activity
5. Create a comparison matrix with weighted criteria

**For "how to implement" questions:**
1. Search for prior art — how have others solved this?
2. Look for official guides, tutorials, and best practices
3. Check for relevant libraries, packages, or frameworks that simplify the problem
4. Identify common patterns and anti-patterns
5. Note any gotchas, edge cases, or known issues

**For architectural questions:**
1. Research established architectural patterns that apply
2. Find case studies of similar systems
3. Evaluate trade-offs: complexity, performance, maintainability, scalability
4. Check for emerging patterns or recent innovations
5. Consider the project's specific constraints

**For brownfield/codebase questions:**
1. Analyze the existing codebase for relevant patterns using Grep and Glob
2. Identify how the codebase currently handles similar concerns
3. Map dependencies and integration points
4. Note technical debt or patterns that constrain options
5. Check test coverage and quality of affected areas

**IMPORTANT:** As you research, keep the user informed with brief progress updates:
```
  ◆ Researching Q1: [question]...
    → Found: [brief finding]
    → Found: [brief finding]
  ✓ Q1 complete.

  ◆ Researching Q2: [question]...
```

### Step 5: Synthesize Findings

After completing research, synthesize findings into a structured document. If the exploration involved a deep novel problem, consider whether to recommend spawning a `titan-investigator` agent for further analysis.

**Decision point — Novel problem detection:**
If during research you discover that:
- No clear prior art exists for the core challenge
- Available solutions are all partial or unsuitable
- The problem requires combining techniques in a new way
- Multiple viable approaches exist with no clear winner

Then recommend: "This appears to be a novel problem. Consider running `/titan:investigate` for a deeper systematic analysis with hypothesis generation and evaluation."

### Step 6: Write EXPLORATION.md

Write the exploration document to the appropriate location:
- Phase-specific: `.titan/phases/[NN-phase-name]/EXPLORATION.md`
- Project-wide: `.titan/EXPLORATION.md`

```markdown
# Exploration — [Topic]

> Generated by /titan:04-explore on [date]
> Scope: [phase-specific | project-wide | technology evaluation | ...]

## Research Questions
1. [Question 1]
2. [Question 2]
3. [Question 3]

## Findings

### Q1: [Question]

**Summary:** [2-3 sentence answer]

**Details:**
[Detailed findings with specific facts, numbers, and sources]

**Key Sources:**
- [Source 1]: [what was learned]
- [Source 2]: [what was learned]

**Confidence:** [High | Medium | Low] — [reason for confidence level]

### Q2: [Question]
...

## Technology Comparison
[If applicable — create a comparison matrix]

| Criterion | Weight | [Option A] | [Option B] | [Option C] |
|-----------|--------|-----------|-----------|-----------|
| [criterion 1] | [H/M/L] | [score + notes] | [score + notes] | [score + notes] |
| [criterion 2] | [H/M/L] | ... | ... | ... |
| **Recommendation** | | | ★ | |

## Recommendations

### Primary Recommendation
[Clear recommendation with rationale]

### Alternative Approaches
1. **[Alternative 1]:** [when this would be better]
2. **[Alternative 2]:** [when this would be better]

## Risks & Unknowns
| Risk | Severity | Mitigation |
|------|----------|-----------|
| [remaining risk 1] | [H/M/L] | [how to handle] |

## Impact on Project
- **Architecture:** [any changes or confirmations to ARCHITECTURE.md]
- **Roadmap:** [any changes to phasing or estimates]
- **Requirements:** [any new requirements or constraint changes discovered]

## Open Questions
[Any questions that could not be answered and need further investigation]
- [Question]: [why it matters, suggested next step]
```

### Step 7: Update KNOWLEDGE.md

Append key learnings to `.titan/KNOWLEDGE.md` under the appropriate section:

```markdown
## Technology Notes
- [date]: [Key learning from exploration, e.g., "React Server Components require Node 18+ and are not compatible with the current Vite setup"]
- [date]: [Another key learning]
```

Only add facts that will be useful in future sessions. Be specific and actionable, not vague.

### Step 8: Update DECISIONS.md

If the exploration resulted in any technology or architectural decisions, add them to `.titan/DECISIONS.md`:

```markdown
| [N] | [today] | [Decision] | [Rationale from exploration] | [Yes/No] |
```

### Step 9: Display Completion Summary

Print (as markdown, NOT in a code block):

---

## ✓ TITAN — EXPLORATION COMPLETE

| Detail | Value |
|--------|-------|
| **Topic** | [exploration topic] |
| **Questions Researched** | [N] |
| **Confidence** | [overall confidence level] |

**Key Findings:**
- [1-2 sentence summary of most important finding]
- [1-2 sentence summary of second most important finding]

**Recommendation:** [Primary recommendation]

[If novel problem detected:]
> ⚠ **Novel problem detected.** Consider `/titan:investigate` for deeper analysis before proceeding.

---

### ★ Recommended

> [Context-dependent guidance — most applicable option:]
> - **Ready to build:** Run `/titan:06-plan` to create execution plan
> - **UI needed:** Run `/titan:05-design` for mockups
> - **Deeper analysis needed:** Run `/titan:investigate`
> - **More research needed:** Run `/titan:04-explore` again

### Other options

| Command | Action |
|---------|--------|
| `/titan:06-plan` | Create execution plan for the next phase |
| `/titan:05-design` | Design UI screens referenced in the plan |
| `/titan:investigate` | Deeper novel problem analysis |
| `/titan:04-explore` | Research additional topics |

---

### Step 10: Update STATE.md

Update `.titan/STATE.md`:
- Phase: [current phase number]
- Step: explore (complete)
- Last Action: Exploration complete — [topic] researched, [N] questions answered
- Updated: [timestamp]

Update Next Action based on what makes sense given the findings.

Add a Knowledge Snapshot with the most important finding from this exploration.

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| EXPLORATION.md | `.titan/phases/NN/EXPLORATION.md` or `.titan/EXPLORATION.md` | Research findings and recommendations |
| KNOWLEDGE.md | `.titan/KNOWLEDGE.md` (updated) | Key learnings appended |
| DECISIONS.md | `.titan/DECISIONS.md` (updated) | New decisions recorded |
| STATE.md | `.titan/STATE.md` (updated) | Progress tracked |

## Error Handling

| Error | Resolution |
|-------|-----------|
| No internet / web search unavailable | Rely on built-in knowledge and codebase analysis. Note reduced confidence in findings. Flag which questions need web research. |
| Research yields contradictory information | Present both sides with sources. Let the user decide, or recommend `/titan:experiment` to test empirically. |
| Scope too broad (>7 questions) | Split into multiple exploration sessions. Prioritize the questions that block progress most. |
| User is not sure what to explore | Review ROADMAP.md and ARCHITECTURE.md for unknowns. Suggest: "Let me scan for potential unknowns based on your roadmap." Then identify risky or unfamiliar areas. |
| Existing EXPLORATION.md for this phase | Ask: "An exploration already exists for this phase. Append new findings or replace?" |

## Integration with Other Commands

- **After `/titan:02-vision`:** Explore unknowns identified during architecture discussion
- **Before `/titan:06-plan`:** Ensure the phase's approach is well-understood
- **Triggered by `/titan:08-verify`:** When verification flags knowledge gaps
- **Feeds into `/titan:investigate`:** When exploration reveals a genuinely novel problem
- **Feeds into `/titan:experiment`:** When exploration narrows to 2-3 viable approaches that need empirical testing

## Tips

- It is better to explore too much than too little. Unknown unknowns cause the worst delays.
- Pay attention to confidence levels. Low-confidence findings should trigger either more research or an experiment.
- When evaluating technologies, always check: When was the last release? How many open issues? Is there corporate backing? How large is the community?
- For brownfield projects, always include codebase analysis in the research — the existing code constrains your options.
- This command can be run multiple times. Each run produces a new EXPLORATION.md or appends to an existing one. Knowledge accumulates.

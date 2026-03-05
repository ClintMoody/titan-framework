---
name: titan:investigate
description: Novel problem solving -- systematic approach to unknowns
---

# /titan:investigate -- Novel Problem Solving

> TITAN'S KEY DIFFERENTIATOR. Use this command when you face a problem that nobody has solved
> before (or that YOU have never solved before). This is not for debugging known issues -- it
> is for exploring the unknown. How should I architect this? Can these two technologies work
> together? What is the best approach for this requirement nobody has documented?
>
> Spawns a titan-investigator agent with a fresh 200k context window for deep research.
> Produces a structured investigation document that chains to `/titan:experiment` for
> hands-on validation.

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` first)
- A clear sense that you face an UNKNOWN -- you cannot just look up the answer
- STATE.md is accessible and writable

## Process

### Step 1: Display Banner and Capture the Problem

```
+==============================================================+
|  ++ TITAN -- INVESTIGATION                                   |
+==============================================================+
```

Read `.titan/STATE.md`, `.titan/KNOWLEDGE.md`, and `.titan/DECISIONS.md` for existing context.

The user provides the problem as the command argument or in a follow-up message. Examples:

- `/titan:investigate How to implement real-time collaboration with CRDTs vs OT`
- `/titan:investigate Best approach for processing 10M records with <2s latency`
- `/titan:investigate Can we integrate Rust WASM modules into our Next.js build pipeline`

If no problem is provided, ask:

> "What problem are you trying to solve? Describe it as specifically as you can."

### Step 2: Assign Investigation ID

Investigations use a 3-digit sequential counter: `001`, `002`, `003`, etc.

Read `.titan/investigations/` to find the highest existing ID. Increment by 1.

Generate a slug from the problem description (lowercase, hyphens, max 40 chars).

Create directory: `.titan/investigations/NNN-slug/`

### Step 3: Problem Articulation

This is the most important step. A well-defined problem is half-solved.

Engage the user in a structured dialog to extract:

1. **What is unknown?** -- The core question that needs answering. State it as precisely as possible.
2. **What do we know?** -- Existing constraints, requirements, decisions already made, technology already committed to.
3. **What does success look like?** -- Concrete criteria for a good solution. Performance targets, user experience goals, maintainability requirements, cost constraints.
4. **What are the constraints?** -- Hard limits that cannot be violated (budget, timeline, existing stack, team size, regulatory).
5. **What have we already tried or considered?** -- Prior approaches and why they were rejected or remain open.
6. **What is the impact?** -- Why does this matter? What happens if we get it wrong?

Write the articulation to `INVESTIGATION.md`:

```markdown
# Investigation #NNN: [problem title]

## Status: IN PROGRESS
## Started: [ISO timestamp]
## Investigator: titan-investigator

---

## 1. Problem Articulation

### The Unknown
[Precise statement of what we need to figure out]

### What We Know
- [Fact 1]
- [Fact 2]
- [Existing constraints and commitments]

### Success Criteria
| Criterion | Target | Priority |
|-----------|--------|----------|
| [criterion] | [target] | MUST / SHOULD / NICE |

### Hard Constraints
- [Constraint 1 -- cannot be violated]
- [Constraint 2]

### Prior Considerations
- [Anything already tried or discussed]

### Impact
[Why this matters and what is at stake]
```

### Step 4: Prior Art Research

Spawn a titan-investigator agent with a fresh context window. The agent's mission:

**Research the problem space exhaustively.** Sources to check:

1. **Official documentation** -- For all relevant technologies
2. **GitHub** -- Search for repositories, issues, discussions that address similar problems
3. **Stack Overflow / forums** -- Community solutions and known pitfalls
4. **Blog posts and articles** -- Practitioner experiences (prioritize recent, reputable sources)
5. **Academic papers** -- If the problem has a theoretical dimension (algorithms, data structures, protocols)
6. **Conference talks** -- Practical insights from experts
7. **The project's own codebase** -- Are there partial solutions or related patterns already present?
8. **`.titan/KNOWLEDGE.md`** -- Has this project encountered related problems before?

For each source found, record:

```markdown
## 2. Prior Art

### Source 1: [title]
- **URL/Location:** [link or file path]
- **Relevance:** [high/medium/low]
- **Key insight:** [what this source contributes to solving the problem]
- **Limitation:** [why this alone does not solve our problem]

### Source 2: [title]
...

### Research Summary
[2-3 paragraph synthesis: what the research landscape looks like, where consensus exists,
where there are open questions, and what gaps remain]
```

### Step 5: Hypothesis Generation

Generate a MINIMUM of 3 distinct approaches. Each approach MUST be genuinely different -- not
variations of the same idea. For each approach:

```markdown
## 3. Hypotheses

### Approach A: [name]

**Description:** [2-3 paragraphs explaining the approach in detail. How it works, what
technologies it uses, what the architecture looks like.]

**Pros:**
- [Advantage 1]
- [Advantage 2]
- [Advantage 3]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Risks:**
- [Risk 1 -- what could go wrong and how likely is it]
- [Risk 2]

**Effort Estimate:** [rough T-shirt size: S / M / L / XL]

**Prior Art Support:** [which sources support this approach]

**Unknowns:** [what we still would not know even after choosing this approach]

---

### Approach B: [name]
...

### Approach C: [name]
...
```

When generating approaches, actively fight the anchoring bias. Do NOT generate one "obvious"
approach and two strawmen. Each approach should be a legitimate contender.

### Step 6: Evaluation Criteria

Define the criteria by which approaches will be judged. These come from the success criteria
in Step 3, plus technical considerations:

```markdown
## 4. Evaluation Framework

### Criteria
| # | Criterion | Weight | Measurement |
|---|-----------|--------|-------------|
| C1 | [e.g., Performance] | [1-5] | [how to measure] |
| C2 | [e.g., Maintainability] | [1-5] | [how to assess] |
| C3 | [e.g., Learning curve] | [1-5] | [how to estimate] |
| C4 | [e.g., Risk level] | [1-5] | [how to evaluate] |
| C5 | [e.g., Alignment with existing stack] | [1-5] | [how to check] |

### Trade-off Map
[Which criteria are in tension? E.g., "Performance vs. Maintainability" or
"Feature richness vs. Time to implement"]
```

### Step 7: Rapid Assessment

Score each approach against the evaluation criteria. This is a preliminary, analytical
assessment -- NOT a substitute for experimentation.

```markdown
## 5. Assessment

### Scoring Matrix
| Criterion (weight) | Approach A | Approach B | Approach C |
|--------------------|-----------|-----------|-----------|
| C1 (w:4) | [1-5] | [1-5] | [1-5] |
| C2 (w:3) | [1-5] | [1-5] | [1-5] |
| C3 (w:2) | [1-5] | [1-5] | [1-5] |
| C4 (w:5) | [1-5] | [1-5] | [1-5] |
| C5 (w:3) | [1-5] | [1-5] | [1-5] |
| **Weighted Total** | **[N]** | **[N]** | **[N]** |

### Analysis
[Narrative analysis of the scores. Where are the clear winners? Where is it close?
What would change the ranking?]
```

### Step 8: Recommendation

```markdown
## 6. Recommendation

### Primary Recommendation: Approach [X]

**Rationale:** [3-5 sentences explaining why this approach wins, acknowledging trade-offs]

**Confidence Level:** [HIGH / MEDIUM / LOW]
- HIGH: Clear winner, prior art is strong, risks are manageable
- MEDIUM: Best option but some unknowns remain -- experimentation recommended
- LOW: No clear winner -- experimentation is essential before committing

### If Confidence is MEDIUM or LOW:
**Experiment Plan:** Run `/titan:experiment` to validate:
- Experiment 1: [what to test about the recommended approach]
- Experiment 2: [what to test about the runner-up approach]

### Decision Required
[Clearly state what decision the user needs to make, with the information they need to make it]
```

### Step 9: Update State and Present

Update `.titan/STATE.md`:

```
- Last Action: Investigation #NNN completed -- [slug]
```

Record the recommendation in `.titan/DECISIONS.md` if the user accepts it:

```
| [N] | [decision description] | [rationale summary] | [date] |
```

Update `.titan/KNOWLEDGE.md` with key learnings from the research.

Print (as markdown, NOT in a code block):

---

## ✓ TITAN — INVESTIGATION COMPLETE

| Detail | Value |
|--------|-------|
| **Problem** | [one-line description] |
| **Approaches evaluated** | [N] |
| **Recommendation** | [Approach name] |
| **Confidence** | [HIGH/MEDIUM/LOW] |

**Rationale:** [2-3 sentences]

[If MEDIUM/LOW confidence:]
> **Suggested next step:** `/titan:experiment` to validate the recommendation

> Full report: `.titan/investigations/NNN-slug/INVESTIGATION.md`

---

## Outputs

| File | Content |
|------|---------|
| `.titan/investigations/NNN-slug/INVESTIGATION.md` | Complete investigation record |

## State Updates

- `STATE.md` Last Action updated
- `DECISIONS.md` updated if user accepts recommendation
- `KNOWLEDGE.md` updated with research findings

## Error Handling

- **Problem is too vague:** Push back. Ask clarifying questions until the problem is specific enough to research. "I want to build something cool" is not a problem statement.
- **No prior art found:** This is actually valuable information. Document the gap. The investigation continues with hypothesis generation based on first principles.
- **All approaches have critical flaws:** Document this honestly. Recommend revisiting the constraints -- perhaps a constraint can be relaxed, or the problem can be decomposed into smaller, solvable sub-problems.
- **User disagrees with recommendation:** Record their reasoning. Update the assessment. The user always has final say -- document their choice and rationale in DECISIONS.md.

## Context Bracket Behavior

| Bracket | Adaptation |
|---------|------------|
| FRESH | Full investigation with deep research. 3-5 approaches. Detailed scoring. |
| MODERATE | Standard investigation. 3 approaches minimum. Standard scoring. |
| DEEP | Abbreviated investigation. 2-3 approaches. Focus on recommendation. Save detailed research for experiment phase. |
| CRITICAL | Save problem articulation and any progress to INVESTIGATION.md. Create handoff for fresh session. |

## Chaining

- `/titan:investigate` --> `/titan:experiment`: When confidence is MEDIUM or LOW, chain to experiment to validate the recommendation with hands-on prototyping.
- `/titan:investigate` --> `/titan:learn`: When research reveals a technology the team is unfamiliar with, chain to learn for a deep dive before committing.
- `/titan:investigate` --> `/titan:05-plan`: When confidence is HIGH and the approach is clear, chain directly to planning the implementation.

## Tips

- The quality of the investigation depends entirely on the quality of the problem articulation in Step 3. Spend time here. A vague question gets a vague answer.
- Fight the urge to jump to the "obvious" solution. The entire point of investigation is to discover that the obvious solution has hidden problems, or that a non-obvious solution is actually superior.
- Investigations are reusable. When a similar problem appears in a future project, the investigation document is a head start.
- The minimum-3-approaches rule exists to prevent anchoring bias. Even if one approach seems clearly best, the exercise of articulating alternatives often reveals insights.
- Record EVERYTHING. The user might reject the recommendation today but revisit it in 3 months when constraints change.

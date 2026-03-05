---
name: titan:learn
description: Deep research on a technology, pattern, or concept before using it
---

# /titan:learn — Research Before You Build

> Use when you need to understand a technology, pattern, library, or concept before incorporating it into your project. TITAN believes in informed decisions — learn first, build second.

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` if not)
- A topic you want to learn about

## Process

### Step 1 — Define the Learning Goal

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — LEARN                                            ║
╚══════════════════════════════════════════════════════════════╝
```

Ask the user: **"What do you want to learn about?"**

Follow up to clarify scope:
- Is this a technology (React, PostgreSQL, WebSockets)?
- A pattern (CQRS, event sourcing, repository pattern)?
- A concept (OAuth 2.0, WebRTC, service workers)?
- A specific library or API?

Also ask: **"What's the context? How will you use this in your project?"**
This focuses the research on what's actually relevant.

### Step 2 — Research

Conduct thorough research using available tools:

1. **Official Documentation** — Search for and read official docs. These are always the primary source.
2. **Key Concepts** — Identify the 5-10 most important concepts to understand.
3. **Architecture/Mental Model** — How does this technology/pattern work conceptually? What's the mental model?
4. **Code Examples** — Find real, practical examples. Prefer examples from reputable sources.
5. **Common Pitfalls** — What do people get wrong? What are the gotchas?
6. **Best Practices** — What does the community recommend?
7. **Alternatives** — What are the alternatives? Brief comparison.
8. **Relevance to This Project** — How does this specifically apply to what we're building?

### Step 3 — Synthesize

Create a knowledge document at `.titan/knowledge/[topic-slug].md`:

```markdown
# [Topic Name]

> Researched: [ISO date] | Context: [project name]

## What It Is
[2-3 sentence explanation in plain language]

## Key Concepts
1. **[Concept]** — [explanation]
2. **[Concept]** — [explanation]
...

## How It Works
[Mental model / architecture explanation. Diagrams in ASCII if helpful.]

## Practical Examples
[Code examples with comments explaining each part]

## Common Pitfalls
- **[Pitfall]** — [why it happens, how to avoid]
...

## Best Practices
- [Practice with brief rationale]
...

## Alternatives
| Alternative | Pros | Cons | When to Use |
|------------|------|------|-------------|
...

## Application to This Project
[Specific recommendations for how to use this in the current project]

## Sources
- [source 1]
- [source 2]
```

### Step 4 — Update Knowledge Base

Append a summary entry to `.titan/KNOWLEDGE.md`:

```markdown
### [Topic Name] ([date])
[1-2 sentence summary of key takeaway. Link to full document: .titan/knowledge/[slug].md]
```

### Step 5 — Present and Discuss

Present the key findings to the user in a concise summary. Highlight:
- The 3 most important things to know
- The biggest pitfall to avoid
- The recommended approach for this project

Ask if they have follow-up questions. Engage in a teaching conversation if they want to go deeper.

## Outputs

- `.titan/knowledge/[topic-slug].md` — Full research document
- Updated `.titan/KNOWLEDGE.md` — Summary entry added

## State Updates

- STATE.md: Last Action updated to "Learned: [topic]"

## Error Handling

- **Topic too broad:** Ask user to narrow scope (e.g., "React" → "React Server Components")
- **No good sources found:** Report what was found, suggest alternative search terms, ask user if they have specific resources to review
- **Topic already researched:** Check if `.titan/knowledge/[slug].md` exists. If so, offer to update or show existing research.

## What's Next

After the research is complete, display (as markdown, NOT in a code block):

---

### ★ Recommended

> **Apply what you learned.**
> [If pre-planning: Run `/titan:05-plan` to plan the phase with this knowledge.]
> [If mid-build: Continue `/titan:06-build` — your KNOWLEDGE.md is updated.]
> [If standalone: Run `/titan:progress` to see your current position.]

### Other options

| Command | Action |
|---------|--------|
| `/titan:learn` | Research another related topic |
| `/titan:investigate` | Investigate if the topic raises novel problems |
| `/titan:experiment` | Try multiple approaches based on what you learned |
| `/titan:03-explore` | Broader exploration of the problem space |

---

## Tips

- Learning BEFORE implementing saves 10x the time learning DURING implementation.
- The "Application to This Project" section is the most valuable part — always include it.
- Don't over-research. Focus on what's needed to make informed decisions for the current phase.
- Knowledge documents are cumulative — each `/titan:learn` makes the project smarter.

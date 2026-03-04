---
name: titan:04-design
description: Conversational UI/UX design — interview, mockup generation via titan-designer agent, iterative review
---

# /titan:04-design — UI/UX Design

> Run this command for projects with a user interface. Conducts a conversational design interview, delegates mockup generation to the titan-designer agent, and iterates until the user approves. Produces a design specification and approved mockups.

## Prerequisites

- `.titan/` directory exists (run `/titan:01-init` first)
- `.titan/PROJECT.md` exists (run `/titan:02-vision` first)
- `.titan/REQUIREMENTS.md` exists (run `/titan:02-vision` first)
- Recommended: `.titan/ARCHITECTURE.md` exists (technology choices inform design tooling)

If prerequisites are not met, inform the user and suggest the correct command.

## Process

### Step 1: Display Banner

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — UI/UX DESIGN                                    ║
╚══════════════════════════════════════════════════════════════╝

  Conversational design → mockup generation → iterative review.
```

### Step 2: UI Applicability Check

Before proceeding, read `.titan/PROJECT.md` and `.titan/ARCHITECTURE.md` to determine if this project has a user interface.

**If the project has NO UI** (API-only service, library, CLI tool, infrastructure, data pipeline):

```
  ⚠ This project does not appear to have a graphical user
    interface. /titan:04-design is for projects with visual UI.

    Project type indicators:
    - [reason why no UI detected, e.g., "API service", "CLI tool"]

    If this project DOES have a UI component I missed,
    tell me and we'll proceed.

    Otherwise, skip this step:
    → /titan:05-plan to create Phase 1 execution plan
```

Wait for user response. If they confirm no UI, exit gracefully and update STATE.md with "Design: skipped (no UI)". If they say there IS a UI, proceed.

**If the project has a CLI interface only:**

```
  ◆ This project has a command-line interface.

  Would you like to:
  1. Design the CLI experience (commands, flags, output format, help text)
  2. Skip design (proceed directly to planning)

  CLI design focuses on command structure and user experience,
  not visual mockups.
```

If they choose CLI design, conduct a shortened interview focused on command structure, output formatting, error messages, and help text. Write `design/BRIEF.md` with CLI-specific content. Skip mockup generation.

**If the project HAS a visual UI**, proceed with the full design process below.

### Step 3: Design Interview

Conduct a conversational interview about the UI. This is NOT a questionnaire — it is a natural dialogue. Ask 1-2 questions at a time, wait for answers, ask follow-ups.

**Opening:**
```
─── Design Interview ────────────────────────────────────────

  Let's design the user experience.

  First: who is the primary user of this interface, and
  what is the single most important thing they need to
  accomplish? Paint me a picture of their typical session.
```

**Topics to cover through natural conversation:**

1. **User Flows** — What are the 3-5 key things a user does? Walk through each flow step by step.
   - "Walk me through what happens when a user [primary action]."
   - "After they do that, what happens next?"
   - "Where does this flow start — what screen are they on?"

2. **Key Screens/Views** — Identify the distinct screens or views needed.
   - "Based on these flows, it sounds like we need these screens: [list]. Does that match your mental model?"
   - "Are there any screens I'm missing?"
   - "Which screen will users spend the most time on?"

3. **Visual Direction** — Understand the desired look and feel.
   - "What feeling should the UI convey? (professional, playful, minimal, rich, technical, friendly)"
   - "Are there any existing products whose visual style you admire? Not to copy, but as a reference point."
   - "Dark mode, light mode, or both?"
   - "Any brand colors, logos, or visual assets that need to be incorporated?"

4. **Layout Preferences** — Structure and navigation.
   - "How should navigation work? Sidebar? Top bar? Bottom tabs?"
   - "Is this primarily a desktop experience, mobile, or both?"
   - "Dense information display or spacious and minimal?"

5. **Component Needs** — Tables, forms, charts, media players, etc.
   - "What types of content will be displayed? Text, images, tables, charts, video?"
   - "Are there complex forms? If so, walk me through the fields."
   - "Any real-time/live updating elements?"

6. **Accessibility & Responsive** — Important constraints.
   - "Any specific accessibility requirements beyond the basics?"
   - "What are the key breakpoints — desktop only, or mobile-responsive?"

**After the interview feels complete** (key screens identified, visual direction clear, user flows mapped):

### Step 4: Write Design Brief

Write `design/BRIEF.md` (create the `design/` directory at project root if it does not exist):

```markdown
# Design Brief — [Project Name]

> Generated by /titan:04-design on [date]

## Target User
[Primary user persona and their context of use]

## User Flows

### Flow 1: [Name, e.g., "User Registration"]
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Flow 2: [Name]
...

## Screen Inventory
| Screen | Purpose | Priority | Key Elements |
|--------|---------|----------|-------------|
| [screen 1] | [purpose] | P0 | [list] |
| [screen 2] | [purpose] | P1 | [list] |

## Visual Direction
- **Mood:** [e.g., "Clean, professional, trustworthy"]
- **Color Palette:** [described or specified — e.g., "Blues and whites, minimal accent color"]
- **Typography:** [preference — e.g., "Modern sans-serif, readable at small sizes"]
- **Density:** [spacious | balanced | dense]
- **Mode:** [light | dark | both]
- **Reference Products:** [if user mentioned any]

## Layout
- **Navigation:** [sidebar | top bar | bottom tabs | ...]
- **Primary Viewport:** [desktop | mobile | both]
- **Responsive Strategy:** [mobile-first | desktop-first | desktop-only]

## Component Requirements
- [List specific UI components needed: tables, forms, charts, media players, etc.]
- [Note any complex or unusual components]

## Accessibility
- [Specific requirements, e.g., "WCAG 2.1 AA", "Keyboard navigable", "Screen reader support"]

## Brand Assets
- [Logo, colors, fonts, or "none — design from scratch"]

## Mockup Priority
Generate mockups in this order:
1. [Most important screen — e.g., "Main dashboard"]
2. [Second screen]
3. [Third screen]
```

Print: "✓ Design brief created at `design/BRIEF.md`."

### Step 5: Generate Mockups via titan-designer Agent

**CRITICAL: NEVER generate HTML mockup code inline in the conversation. ALWAYS delegate mockup creation to the titan-designer agent.**

The titan-designer agent is a subagent that receives the design brief and produces browser-testable HTML mockup files. The orchestrator (you) must:

1. **Spawn the titan-designer agent** with the following inputs:
   - The full content of `design/BRIEF.md`
   - The project domain from `.titan/config.yaml`
   - The technology stack from `.titan/ARCHITECTURE.md` (so mockups use appropriate styling frameworks)
   - Which screen to generate (start with the highest-priority screen from the brief)

2. **The titan-designer agent will:**
   - Create a self-contained HTML file per screen in `design/mockups/`
   - Each file is a single `.html` file with inline CSS and minimal inline JS
   - Files must be viewable by opening directly in a browser (no build step)
   - Use realistic placeholder content (not "Lorem ipsum" — use content that resembles real data)
   - Follow the visual direction from the brief
   - Include responsive behavior if specified in the brief
   - Name files descriptively: `01-dashboard.html`, `02-settings.html`, etc.

3. **After the agent completes each mockup:**
   - Inform the user: "Mockup ready: `design/mockups/[filename].html` — please open it in your browser to review."
   - If a preview server is available, offer to launch it.

### Step 6: Review and Iteration Loop

After the user has viewed the mockup, ask for feedback:

```
─── Mockup Review ───────────────────────────────────────────

  Screen: [screen name]
  File:   design/mockups/[filename].html

  What do you think? Options:

  ✓ "approve" or "looks good"  → Lock this mockup, move to next screen
  ◆ Give specific feedback     → I'll update and regenerate
  ✗ "start over"               → Regenerate from scratch with new direction

  Be as specific as possible with feedback. Examples:
  - "The sidebar is too wide"
  - "Move the search bar to the top"
  - "Use a darker shade of blue"
  - "The table needs pagination"
  - "Add a loading state"
```

**Iteration rules:**
- On feedback: Update the design brief with the feedback notes, re-spawn titan-designer with the specific changes requested. Do NOT regenerate the entire brief — just pass the feedback as modification instructions.
- On "start over": Ask what should change about the visual direction, update the brief, regenerate.
- On "approve": Mark the screen as approved. Move to the next screen in priority order.
- Maximum 5 iterations per screen. If after 5 rounds the user is still not satisfied, suggest: "We might benefit from a more detailed reference. Can you share a screenshot or URL of a design you like?"

**Continue until all priority screens have approved mockups.**

### Step 7: Write Design Spec

After all mockups are approved, synthesize the approved designs into a specification document.

Write `design/SPEC.md`:

```markdown
# Design Specification — [Project Name]

> Generated by /titan:04-design on [date]
> Based on [N] approved mockups.

## Visual Language

### Color Palette
| Name | Hex | Usage |
|------|-----|-------|
| Primary | #[hex] | Buttons, links, active states |
| Secondary | #[hex] | Accents, hover states |
| Background | #[hex] | Page background |
| Surface | #[hex] | Card/panel background |
| Text Primary | #[hex] | Headings, body text |
| Text Secondary | #[hex] | Labels, secondary info |
| Success | #[hex] | Success states, confirmations |
| Warning | #[hex] | Warnings, caution states |
| Error | #[hex] | Errors, destructive actions |
| Border | #[hex] | Dividers, outlines |

### Typography
| Element | Font | Size | Weight | Line Height |
|---------|------|------|--------|-------------|
| H1 | [font] | [size] | [weight] | [height] |
| H2 | [font] | [size] | [weight] | [height] |
| Body | [font] | [size] | [weight] | [height] |
| Small | [font] | [size] | [weight] | [height] |
| Button | [font] | [size] | [weight] | [height] |

### Spacing Scale
- **xs:** [value] (e.g., 4px)
- **sm:** [value] (e.g., 8px)
- **md:** [value] (e.g., 16px)
- **lg:** [value] (e.g., 24px)
- **xl:** [value] (e.g., 32px)
- **2xl:** [value] (e.g., 48px)

### Border Radius
- **Small:** [value] (inputs, badges)
- **Medium:** [value] (cards, panels)
- **Large:** [value] (modals, hero sections)
- **Full:** 9999px (pills, avatars)

### Shadows
- **sm:** [value] (cards at rest)
- **md:** [value] (dropdowns, popovers)
- **lg:** [value] (modals, dialogs)

## Components

### Buttons
| Variant | Background | Text | Border | Hover | Disabled |
|---------|-----------|------|--------|-------|----------|
| Primary | [color] | [color] | none | [behavior] | [style] |
| Secondary | [color] | [color] | [color] | [behavior] | [style] |
| Ghost | transparent | [color] | none | [behavior] | [style] |
| Danger | [color] | [color] | none | [behavior] | [style] |

### Form Elements
[Input fields, selects, checkboxes, radio buttons — describe visual treatment]

### Navigation
[Describe the navigation component: structure, active states, responsive behavior]

### Cards/Panels
[Describe card component: padding, borders, shadows, hover states]

### Tables
[If applicable: header style, row style, striping, hover, pagination]

### Modals/Dialogs
[If applicable: overlay, sizing, close behavior, animation]

## Screen Specifications

### [Screen 1 Name]
- **Mockup:** `design/mockups/[filename].html`
- **Layout:** [description of layout structure]
- **Key Interactions:** [hover states, click targets, transitions]
- **Responsive Behavior:** [how it adapts at breakpoints]

### [Screen 2 Name]
...

## Responsive Breakpoints
| Name | Width | Layout Changes |
|------|-------|---------------|
| Mobile | < 640px | [changes] |
| Tablet | 640-1024px | [changes] |
| Desktop | > 1024px | [default] |

## Accessibility Notes
- [Specific accessibility decisions made during design]
- [Color contrast ratios for key combinations]
- [Focus indicator styles]
- [Touch target sizes]

## Animation & Transitions
- **Page transitions:** [if any]
- **Micro-interactions:** [hover, focus, click feedback]
- **Loading states:** [skeleton, spinner, progress bar]
- **Duration standard:** [e.g., 150ms for micro, 300ms for transitions]
```

### Step 8: Copy Approved Mockups

Ensure all approved mockup files are present in `design/mockups/` at the project root. List them for the user:

```
  Approved Mockups:
    ✓ design/mockups/01-[screen].html
    ✓ design/mockups/02-[screen].html
    ✓ design/mockups/03-[screen].html
```

### Step 9: Display Completion Summary

```
╔══════════════════════════════════════════════════════════════╗
║  ✓ TITAN — DESIGN COMPLETE                                  ║
╚══════════════════════════════════════════════════════════════╝

  Artifacts Created:
    ✓ design/BRIEF.md                Design brief
    ✓ design/SPEC.md                 Design specification
    ✓ design/mockups/[N] files       Approved HTML mockups

  Design Summary:
    Screens:    [N] screens designed and approved
    Iterations: [N] total revision rounds
    Style:      [brief visual description, e.g., "Clean, dark-themed dashboard"]

  What's Next:
  ─────────────────────────────────────────────────
  → Run /titan:05-plan to create Phase 1 execution plan.
    The plan will reference these approved mockups as
    implementation targets.
  ─────────────────────────────────────────────────
```

### Step 10: Update State

Update `.titan/STATE.md`:
- Phase: [current phase number]
- Step: design (complete)
- Last Action: UI design complete — [N] screens approved, design spec created
- Updated: [timestamp]

Add to Completed Phases if this is a project-level design pass:
| 03 | UI/UX Design | ✓ Complete | [today] |

Update Next Action: "Run `/titan:05-plan` to create Phase 1 execution plan."

Add design decisions to `.titan/DECISIONS.md`:
- Key technology choices (CSS framework, component library, etc.)
- Visual direction decisions
- Navigation pattern choice

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| BRIEF.md | `design/BRIEF.md` | Design interview results and requirements |
| SPEC.md | `design/SPEC.md` | Approved design specification (colors, typography, spacing, components) |
| HTML Mockups | `design/mockups/*.html` | Browser-viewable approved screen mockups |
| STATE.md | `.titan/STATE.md` (updated) | Progress tracked |
| DECISIONS.md | `.titan/DECISIONS.md` (updated) | Design decisions recorded |

## Error Handling

| Error | Resolution |
|-------|-----------|
| No UI detected but user insists | Trust the user. Proceed with design interview. They know their project. |
| User cannot describe visual direction | Offer 3 concrete directions: "Option A: Minimal and clean (think Notion). Option B: Rich and detailed (think Jira). Option C: Bold and modern (think Linear). Which resonates?" |
| titan-designer agent unavailable | Fall back to generating mockups in the current session. Warn: "Generating mockup inline — for best results, the titan-designer agent should be used." Generate the HTML directly. |
| User wants to use Figma/external tools | Acknowledge their preference. Offer: "You can design externally and share screenshots. I'll create the SPEC.md based on your screenshots." Skip mockup generation, go straight to spec. |
| Mockup does not render correctly | Check for syntax errors in the HTML. Regenerate. If persistent, simplify the mockup (fewer components, simpler layout). |
| User approves but wants changes later | That is fine. They can re-run `/titan:04-design` to iterate further, or make changes during the build phase. Note in STATE.md. |
| Too many screens to design | Prioritize ruthlessly. Design the top 3-5 screens. The rest can be designed during their respective build phases. "Let's focus on the core screens now and design the rest when we build those phases." |

## Integration with Other Commands

- **After `/titan:02-vision`:** Design uses PROJECT.md for user context and REQUIREMENTS.md for feature scope.
- **After `/titan:03-explore`:** Exploration may have identified UI patterns or libraries to use.
- **Before `/titan:05-plan`:** Plans reference approved mockups as implementation targets.
- **During `/titan:06-build`:** Executor agents reference mockups and SPEC.md for pixel-accurate implementation.
- **During `/titan:07-verify`:** Verifier checks implementation against approved mockups and SPEC.md.

## What's Next

After design is complete, display:

```
─────────────────────────────────────────────────
★ Recommended: Run /titan:05-plan to create the Phase 1 execution plan.
  Your approved designs will be used as implementation targets.

Other options:
  /titan:03-explore   — Research technologies or unknowns before planning
  /titan:04-design    — Re-run to iterate on designs or add more screens
  /titan:progress  — See full project dashboard and current position
─────────────────────────────────────────────────
```

## Tips

- Start with the most complex screen. If you can get that right, simpler screens follow quickly.
- Realistic placeholder content makes mockups far more useful than generic "Lorem ipsum" text.
- If the user is indecisive about visual direction, show them two contrasting mockups of the same screen and ask which they prefer. Concrete examples beat abstract descriptions.
- The SPEC.md is what developers (and AI agents) actually reference during implementation. Make it precise — specific hex codes, pixel values, font names. Vague specs lead to vague implementations.
- For complex applications, consider designing a component library mockup first (buttons, inputs, cards, tables) and then composing screens from those components.

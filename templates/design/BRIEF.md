# ⚡ TITAN — Design Brief

> Captures design intent before creating the design specification.
> Fill this out during exploration or planning, before any UI work begins.

---

## Project Context

### What is this project?
> _One paragraph describing the project and its purpose._

{{PROJECT_DESCRIPTION}}

### What problem does it solve?
> _What pain point or need does this address?_

{{PROBLEM_STATEMENT}}

### What is the scope of design work?
> _Full application redesign? New feature? Component library? Landing page?_

{{DESIGN_SCOPE}}

---

## Target Users

### Primary Audience
- **Who:** {{PRIMARY_USERS}}
- **Technical level:** beginner | intermediate | advanced | mixed
- **Age range:** {{AGE_RANGE}}
- **Usage context:** desktop | mobile | tablet | all devices
- **Usage frequency:** daily | weekly | occasional | one-time

### Secondary Audience
- **Who:** {{SECONDARY_USERS}}
- **How they differ:** {{AUDIENCE_DIFFERENCES}}

### User Goals
1. {{USER_GOAL_1}}
2. {{USER_GOAL_2}}
3. {{USER_GOAL_3}}

---

## Key Screens / Views

List the core screens or views that need design:

| # | Screen | Purpose | Priority | Notes |
|---|--------|---------|----------|-------|
| 1 | {{SCREEN_1}} | {{PURPOSE_1}} | must-have | |
| 2 | {{SCREEN_2}} | {{PURPOSE_2}} | must-have | |
| 3 | {{SCREEN_3}} | {{PURPOSE_3}} | nice-to-have | |

### User Flow
```
[Entry Point] → [Screen 1] → [Screen 2] → [Screen 3] → [Success State]
                     ↓
              [Error State]
```

---

## Visual Direction

### Mood / Feeling
> _What should users feel when they use this? (3-5 adjectives)_

{{MOOD_ADJECTIVES}}

Examples: professional, playful, minimal, warm, technical, luxurious, accessible, bold

### Style Direction
- **Minimalist ←→ Rich:** {{STYLE_SPECTRUM}}
- **Formal ←→ Casual:** {{FORMALITY_SPECTRUM}}
- **Classic ←→ Modern:** {{ERA_SPECTRUM}}
- **Muted ←→ Vibrant:** {{COLOR_SPECTRUM}}

### Brand Guidelines
- **Existing brand?** yes | no | partial
- **Brand colors:** {{BRAND_COLORS}}
- **Logo available?** yes | no
- **Font specified?** {{BRAND_FONT}}
- **Brand voice:** {{BRAND_VOICE}}

> If there are existing brand guidelines, attach them or link to them here.

---

## Content Inventory

### Text Content
| Content Area | Status | Source |
|-------------|--------|--------|
| Headlines/copy | draft | placeholder | final | {{STATUS}} |
| Body text | draft | placeholder | final | {{STATUS}} |
| CTAs/buttons | draft | placeholder | final | {{STATUS}} |
| Error messages | draft | placeholder | final | {{STATUS}} |
| Help text | draft | placeholder | final | {{STATUS}} |

### Media Content
| Asset Type | Available | Format | Notes |
|-----------|-----------|--------|-------|
| Photography | yes | no | {{FORMAT}} | |
| Illustrations | yes | no | {{FORMAT}} | |
| Icons | yes | no | {{FORMAT}} | |
| Video | yes | no | {{FORMAT}} | |
| Animation | yes | no | {{FORMAT}} | |

---

## Platform Constraints

### Technical Constraints
- **Target platforms:** {{PLATFORMS}}
- **Minimum viewport:** {{MIN_VIEWPORT}}
- **Maximum viewport:** {{MAX_VIEWPORT}}
- **Browser support:** {{BROWSER_SUPPORT}}
- **Framework:** {{CSS_FRAMEWORK}}
- **Component library:** {{COMPONENT_LIB}}

### Performance Constraints
- **Target load time:** {{LOAD_TIME}}
- **Image budget:** {{IMAGE_BUDGET}}
- **Animation constraints:** {{ANIMATION_CONSTRAINTS}}

### Content Constraints
- **Internationalization (i18n):** yes | no
- **RTL support:** yes | no
- **Max content length:** {{MAX_CONTENT}}

---

## Accessibility Requirements

### Compliance Target
- **Standard:** WCAG 2.1 Level AA | Level AAA | Section 508 | custom
- **Testing tools:** {{A11Y_TOOLS}}

### Key Requirements
- [ ] Color contrast ratio minimum 4.5:1 (AA) or 7:1 (AAA)
- [ ] Keyboard navigation for all interactive elements
- [ ] Screen reader compatibility (semantic HTML, ARIA labels)
- [ ] Focus indicators visible and clear
- [ ] Text resizable to 200% without layout breakage
- [ ] No content conveyed by color alone
- [ ] Motion/animation respects `prefers-reduced-motion`
- [ ] Touch targets minimum 44x44px on mobile
- [ ] Form labels associated with inputs
- [ ] Error messages descriptive and associated with fields

### Additional Requirements
- {{A11Y_ADDITIONAL}}

---

## Reference Examples

### Inspirations
_Links or descriptions of designs that capture the desired direction._

| Reference | What to take from it | Link |
|-----------|---------------------|------|
| {{REF_1}} | {{TAKEAWAY_1}} | {{LINK_1}} |
| {{REF_2}} | {{TAKEAWAY_2}} | {{LINK_2}} |
| {{REF_3}} | {{TAKEAWAY_3}} | {{LINK_3}} |

### Anti-References
_Designs that represent what we do NOT want._

| Reference | What to avoid | Why |
|-----------|--------------|-----|
| {{ANTI_REF_1}} | {{AVOID_1}} | {{WHY_1}} |

---

## Sign-Off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Product | {{PM_NAME}} | ○ | — |
| Design | {{DESIGNER_NAME}} | ○ | — |
| Engineering | {{ENG_NAME}} | ○ | — |

---

_Created: {{TIMESTAMP}}_
_TITAN v1.0_

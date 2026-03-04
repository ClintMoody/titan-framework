# Common Anti-Patterns Reference

> Things to avoid. Each anti-pattern includes why it's harmful and what to do instead.

---

## Architectural Anti-Patterns

### God Object / God Class
**What:** A single class/module that does everything, knows everything, controls everything.
**Why it's bad:** Impossible to test, understand, or modify independently. Every change risks breaking something.
**Instead:** Split into focused classes with single responsibilities. If a class has more than 5-7 methods, it's probably doing too much.

### Spaghetti Code
**What:** Code with no clear structure — control flow jumps around, dependencies are unclear.
**Why it's bad:** Impossible to follow, debug, or modify. Changes have unpredictable ripple effects.
**Instead:** Establish clear layers, use consistent patterns, keep functions short and focused.

### Big Ball of Mud
**What:** A system with no discernible architecture — everything depends on everything.
**Why it's bad:** The system becomes increasingly fragile and resistant to change.
**Instead:** Define module boundaries, enforce dependency rules, refactor incrementally.

### Premature Microservices
**What:** Starting with microservices before understanding the domain boundaries.
**Why it's bad:** Adds massive operational complexity. Wrong boundaries are expensive to fix.
**Instead:** Start with a modular monolith. Extract services only when you have clear, proven boundaries.

---

## Code Quality Anti-Patterns

### Premature Optimization
**What:** Optimizing code before measuring or even knowing if it's slow.
**Why it's bad:** Wastes time, adds complexity, and the "optimization" often targets the wrong thing.
**Instead:** Write clear, simple code first. Measure. Optimize only proven bottlenecks.

### Copy-Paste Programming
**What:** Duplicating code blocks instead of creating shared abstractions.
**Why it's bad:** Bug fixes must be applied in multiple places. Inconsistencies creep in.
**Instead:** Extract shared logic into functions/components. But don't over-abstract — three similar lines are often better than a premature abstraction.

### Golden Hammer
**What:** Using a familiar tool/pattern for everything, regardless of fit.
**Why it's bad:** Square peg, round hole. The wrong tool adds complexity and reduces quality.
**Instead:** Choose tools and patterns based on the problem. Learn new approaches when needed.

### Magic Numbers / Strings
**What:** Hardcoded values scattered through code without explanation.
**Why it's bad:** Nobody knows what `if (status === 3)` means. Changes require finding every occurrence.
**Instead:** Use named constants. `if (status === OrderStatus.COMPLETED)` is self-documenting.

### Dead Code
**What:** Commented-out code, unused functions, unreachable branches.
**Why it's bad:** Creates confusion ("is this still needed?"), bloats the codebase.
**Instead:** Delete it. Git remembers everything. If you need it later, find it in history.

### Stringly Typed
**What:** Using strings where enums, types, or structured data should be used.
**Why it's bad:** No compiler help, easy to misspell, impossible to refactor safely.
**Instead:** Use enums, union types, or constants. Let the type system catch errors.

---

## Design Anti-Patterns

### Feature Creep
**What:** Continuously adding features without shipping or validating existing ones.
**Why it's bad:** Nothing ships. Complexity grows. Quality degrades. Users get overwhelmed.
**Instead:** Ship the minimum viable feature. Validate with users. Then iterate.

### Inner-Platform Effect
**What:** Building a generic system so flexible it becomes a platform for building the actual system.
**Why it's bad:** You're building two systems instead of one. The generic layer is always worse than a specialized solution.
**Instead:** Build what you need now. Generalize only when you have 3+ concrete use cases.

### Abstraction Inversion
**What:** Building low-level functionality on top of high-level abstractions.
**Why it's bad:** Layers of indirection that add complexity without value. Fighting the framework.
**Instead:** Use the right level of abstraction. If you need low-level control, use a low-level tool.

### Cargo Cult Programming
**What:** Using patterns, frameworks, or practices because "that's what everyone does" without understanding why.
**Why it's bad:** You get the cost of the pattern without the benefit.
**Instead:** Understand WHY a pattern exists. Use it when the problem it solves is YOUR problem.

---

## Data Anti-Patterns

### N+1 Query Problem
**What:** Loading a list, then making a separate query for each item's related data.
**Why it's bad:** Scales linearly with data size. 100 items = 101 queries.
**Instead:** Use joins, eager loading, or DataLoader pattern to batch queries.

### Implicit Schema
**What:** No defined schema — just shoving JSON/objects into a database.
**Why it's bad:** No validation, no documentation, inconsistent data, no migration path.
**Instead:** Define schemas explicitly. Validate at boundaries. Version changes.

### Soft Deletes Everywhere
**What:** Never actually deleting data — just setting `deleted_at`.
**Why it's bad:** Every query needs a WHERE clause. Data grows forever. GDPR compliance issues.
**Instead:** Use soft deletes only where audit trail is required. Hard delete everything else.

---

## Process Anti-Patterns

### Analysis Paralysis
**What:** Spending so much time planning and researching that you never start building.
**Why it's bad:** You learn more from building than from planning. Plans become stale.
**Instead:** Research enough to make an informed decision, then build. Iterate based on real feedback.

### Not Invented Here
**What:** Refusing to use existing solutions and insisting on building everything from scratch.
**Why it's bad:** Wastes time. Your custom solution will have more bugs and fewer features.
**Instead:** Use existing, well-maintained libraries for non-differentiating work. Build custom only for your core value.

### Lava Flow
**What:** Code that's been there forever, nobody understands it, but nobody dares to remove it.
**Why it's bad:** Increases complexity, maintenance burden, and fear of change.
**Instead:** Write tests for it. If it's truly unused, delete it. Git has history.

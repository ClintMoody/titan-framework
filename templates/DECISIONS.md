# ⚡ TITAN — Decision Log

> Every non-obvious decision is recorded here with full context.
> This log enables future developers (human or AI) to understand WHY choices were made.

---

## Decision Record

| # | Date | Phase | Decision | Alternatives Considered | Rationale | Status |
|---|------|-------|----------|------------------------|-----------|--------|
| — | — | — | — | — | — | _No decisions recorded yet_ |

---

## How to Record Decisions

### When to Record

Record a decision when:
- **Choosing between approaches** — Multiple valid solutions exist
- **Deviating from convention** — Breaking from established patterns
- **Making tradeoffs** — Sacrificing one quality for another (speed vs safety, etc.)
- **Selecting dependencies** — Adding a library, tool, or service
- **Architectural choices** — Module boundaries, data flow, API design
- **Process changes** — Modifying the development workflow

### When NOT to Record

Skip recording when:
- The choice is obvious and uncontroversial
- There's only one viable option
- It's a minor stylistic preference covered by existing conventions

### Format

Each decision entry should include:

| Field | Description |
|-------|-------------|
| **#** | Sequential number (D-001, D-002, ...) |
| **Date** | When the decision was made (YYYY-MM-DD) |
| **Phase** | Which phase the decision was made in |
| **Decision** | What was decided (concise, imperative) |
| **Alternatives** | What other options were considered |
| **Rationale** | Why this option was chosen over alternatives |
| **Status** | Current status of the decision |

### Status Values

| Status | Meaning |
|--------|---------|
| `active` | Decision is in effect and being followed |
| `superseded` | Replaced by a newer decision (reference the new one) |
| `revisit` | Needs re-evaluation (add to deferred items) |
| `reversed` | Decision was reversed (document why) |

---

## Example Entry

| # | Date | Phase | Decision | Alternatives Considered | Rationale | Status |
|---|------|-------|----------|------------------------|-----------|--------|
| D-001 | 2025-01-15 | 02 | Use PostgreSQL for primary data store | SQLite, MySQL, MongoDB | Need JSONB support for flexible schemas, strong ACID compliance for financial data, team has PostgreSQL expertise | active |
| D-002 | 2025-01-16 | 02 | Use connection pooling via PgBouncer | Direct connections, Prisma pool | Expected 500+ concurrent connections, PgBouncer provides transparent pooling without ORM lock-in | active |

---

## Decision Dependencies

_Track which decisions depend on or affect other decisions._

> When a decision is superseded or reversed, check this section
> to identify cascading impacts.

| Decision | Depends On | Impacts |
|----------|-----------|---------|
| — | — | _No dependencies tracked yet_ |

---

_Last updated: {{TIMESTAMP}}_
_TITAN v1.0_

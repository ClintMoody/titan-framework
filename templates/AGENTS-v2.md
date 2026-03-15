# ⚡ TITAN Project: {{PROJECT_NAME}}

> This file is loaded at the start of every session.
> Keep it under 100 lines — point to deeper sources, don't duplicate them.

---

## Quick Orientation
- **Architecture:** see `.titan/docs/architecture.md`
- **Current plan:** see `.titan/docs/execution-plan.md`
- **Design decisions:** see `.titan/docs/design/decisions.md`
- **Module specs:** see `.titan/docs/design/module-specs/`
- **Quality status:** see `.titan/docs/quality.md`
- **Domain reference:** see `.titan/docs/domain/`
- **Feature manifest:** see `.titan/MANIFEST.json`
- **Session log:** see `.titan/PROGRESS.md`
- **Loop state:** see `.titan/LOOP-STATE.json`

## Active Constraints
<!-- 5-10 critical rules — module boundaries, naming conventions, etc. -->
1. {{Constraint 1}}
2. {{Constraint 2}}
3. {{Constraint 3}}

## Working Agreements
- All state lives in `.titan/` — context clears lose nothing
- Features tracked in `MANIFEST.json` (JSON, not markdown)
- One feature per session, clean state at end
- Environment must pass smoke test before new work
- All features verified end-to-end before marking "passing"
- Commits use format: `titan(phase-NN): description`
- Never skip verification (`/titan:07-verify`)
- Document non-trivial decisions in `DECISIONS.md`

## Domain: {{DOMAIN}}
<!-- Loaded from domain plugin -->
- Key patterns: {{patterns}}
- Anti-patterns: {{anti_patterns}}

## Session Protocol
1. Read PROGRESS.md (last 3 sessions)
2. Read LOOP-STATE.json
3. Run init.sh + smoke test
4. Fix any existing failures FIRST
5. Select highest-priority failing feature
6. Implement → test → verify E2E
7. Commit → update PROGRESS.md → update LOOP-STATE.json

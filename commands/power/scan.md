---
name: titan:scan
description: Deep codebase analysis with 4 parallel researcher agents
---

# /titan:scan -- Deep Codebase Analysis

> Use this command when joining a brownfield project, onboarding to an unfamiliar codebase, or
> preparing for a major refactoring effort. Spawns 4 parallel titan-researcher agents, each
> with a fresh 200k context window focused on a single analysis dimension. Results feed into
> planning, architecture decisions, and domain configuration.

## Prerequisites

- `.titan/` directory exists (run `/titan:init` first)
- A codebase with actual source files to analyze (not an empty greenfield project)
- STATE.md is accessible and writable

## Process

### Step 1: Display Banner and Confirm Scope

```
+==============================================================+
|  ++ TITAN -- DEEP CODEBASE SCAN                              |
+==============================================================+
```

Read `.titan/STATE.md` and `.titan/config.yaml` to understand the current project context.

Ask the user ONE question:

> "Scan the entire codebase, or focus on specific directories?"

If the user specifies directories, scope all 4 researchers to those paths only.
If the user says "everything" or equivalent, scan from the project root.

Default: scan everything. If the user provides no input, proceed with full scan.

### Step 2: Prepare the Research Directory

Create `.titan/research/` if it does not exist. If prior scan results exist, archive them:

```
.titan/research/archive/YYYY-MM-DD/
```

Move all existing `.md` files from `.titan/research/` into the archive directory.

### Step 3: Spawn 4 Parallel Researcher Agents

Launch all 4 agents simultaneously. Each gets a fresh context window and writes its own output file.
DO NOT run them sequentially -- they MUST run in parallel for efficiency.

---

#### Agent 1: Stack Researcher --> `.titan/research/stack.md`

**Mission:** Map the complete technology stack.

Analyze and document:

1. **Languages** -- Primary and secondary languages, versions detected (from config files, shebangs, file extensions)
2. **Frameworks** -- Core frameworks with exact versions (package.json, Gemfile, requirements.txt, Cargo.toml, go.mod, etc.)
3. **Dependencies** -- Full dependency tree. Flag outdated packages (major versions behind). Count direct vs transitive.
4. **Build System** -- Build tool (webpack, vite, esbuild, make, gradle, cargo, etc.), configuration files, build scripts, output targets
5. **Package Manager** -- npm/yarn/pnpm/pip/cargo/go modules, lockfile presence and freshness
6. **Runtime** -- Node version (.nvmrc, engines), Python version, Java version, etc.
7. **Dev Tools** -- Linters (eslint, prettier, rubocop), formatters, type checkers (TypeScript, mypy, flow)
8. **CI/CD** -- Pipeline files (.github/workflows, .gitlab-ci.yml, Jenkinsfile, etc.)
9. **Infrastructure** -- Docker, docker-compose, Kubernetes manifests, Terraform, serverless configs
10. **Testing Stack** -- Test runner, assertion library, mocking framework, coverage tool

Output format:

```markdown
# Stack Analysis

## Summary
[2-3 sentence overview of the tech stack]

## Languages
| Language | Version | File Count | Lines (approx) |
|----------|---------|------------|-----------------|

## Frameworks
| Framework | Version | Latest | Status |
|-----------|---------|--------|--------|

## Dependencies
- Direct: [count]
- Dev: [count]
- Outdated (major): [list]
- Outdated (minor): [list]

## Build System
[Details]

## Dev Tooling
[Details]

## CI/CD
[Details]

## Key Observations
- [Notable findings, unusual choices, potential issues]
```

---

#### Agent 2: Architecture Researcher --> `.titan/research/architecture.md`

**Mission:** Map the structural design and data flow of the codebase.

Analyze and document:

1. **File Organization** -- Top-level directory structure, naming conventions for directories, organizational pattern (by feature, by layer, by domain, hybrid)
2. **Entry Points** -- Main files, server entry, client entry, CLI entry, test entry
3. **Module System** -- Import/export patterns, module boundaries, circular dependencies
4. **Component Relationships** -- Dependency graph between major modules. Which modules depend on which? Where are the hubs?
5. **Data Flow** -- How data enters the system, transforms, persists, and exits. Request lifecycle for server apps. Event flow for UI apps.
6. **State Management** -- Where state lives (database, in-memory, files, external services). State mutation patterns.
7. **API Surface** -- External APIs exposed (REST, GraphQL, gRPC, WebSocket). Internal APIs between modules.
8. **Configuration** -- How the app is configured (env vars, config files, feature flags, command-line args)
9. **Error Handling** -- Error propagation patterns, error boundaries, logging approach
10. **Key Abstractions** -- The 5-10 most important classes/types/interfaces that define the system's architecture

Output format:

```markdown
# Architecture Analysis

## Summary
[2-3 sentence architectural overview]

## Organization Pattern
[by-feature | by-layer | by-domain | hybrid] -- [explanation]

## Directory Map
[Annotated tree of top-level structure with descriptions]

## Key Abstractions
| Abstraction | Location | Purpose | Dependencies |
|-------------|----------|---------|--------------|

## Data Flow
[Description or ASCII diagram of primary data flow]

## Module Dependency Map
[List major modules and their dependencies]

## API Surface
[External and internal API summary]

## Architectural Patterns
- [Patterns identified: MVC, MVVM, Clean Architecture, Event Sourcing, CQRS, etc.]

## Key Observations
- [Architectural strengths, weaknesses, unusual patterns]
```

---

#### Agent 3: Conventions Researcher --> `.titan/research/conventions.md`

**Mission:** Extract the implicit and explicit rules the codebase follows.

Analyze and document:

1. **Naming Conventions** -- Variables (camelCase, snake_case, PascalCase), files, directories, classes, functions, constants, enums, types/interfaces
2. **Code Formatting** -- Indentation (tabs/spaces, width), line length, bracket style, semicolons, quotes (single/double), trailing commas
3. **File Structure Patterns** -- How individual files are organized (imports at top, exports at bottom, etc.), file length tendencies, one-class-per-file vs multiple
4. **Documentation Style** -- JSDoc, docstrings, inline comments, README patterns, API docs
5. **Testing Conventions** -- Test file naming (`*.test.ts`, `*_test.go`, `test_*.py`), test structure (describe/it, test classes), fixture patterns, mock patterns
6. **Error Handling Patterns** -- try/catch usage, Result types, error codes, custom error classes
7. **Git Conventions** -- Commit message format, branch naming, PR template existence
8. **Import Organization** -- Grouping (stdlib, external, internal), alias patterns, barrel files
9. **Type Usage** -- TypeScript strictness, type annotations, generics usage, `any` frequency
10. **Design Patterns** -- Factory, singleton, observer, strategy, repository, dependency injection -- which ones appear and where

Output format:

```markdown
# Conventions Analysis

## Summary
[2-3 sentence overview of coding style and conventions]

## Naming
| Element | Convention | Example |
|---------|-----------|---------|

## Formatting
| Rule | Value |
|------|-------|

## File Structure
[Typical file layout pattern]

## Testing
| Aspect | Convention |
|--------|-----------|

## Documentation
[Documentation approach and coverage level]

## Design Patterns
| Pattern | Location | Usage |
|---------|----------|-------|

## Explicit Rules
[From linter configs, editorconfig, CONTRIBUTING.md, etc.]

## Implicit Rules
[Patterns observed but not formally documented]

## Inconsistencies
[Places where the codebase contradicts its own conventions]
```

---

#### Agent 4: Concerns Researcher --> `.titan/research/concerns.md`

**Mission:** Identify technical debt, security issues, performance risks, and code smells.

Analyze and document:

1. **Technical Debt** -- TODO/FIXME/HACK/XXX comments (count and categorize), dead code, unused dependencies, deprecated API usage
2. **Security Issues** -- Hardcoded secrets (API keys, passwords, tokens), SQL injection vectors, XSS opportunities, insecure dependencies (CVEs if detectable), missing input validation, open CORS, missing auth checks
3. **Performance Bottlenecks** -- N+1 queries, missing indexes (if schema visible), synchronous I/O in async context, unbounded loops, missing pagination, large bundle imports, memory leak patterns
4. **Code Smells** -- God classes/files (>500 lines), deeply nested logic (>4 levels), long parameter lists (>5 params), duplicated code blocks, feature envy, shotgun surgery indicators
5. **Test Coverage Gaps** -- Untested critical paths, missing edge case tests, test files that are stubs, disabled/skipped tests
6. **Dependency Risks** -- Unmaintained packages (no updates in 2+ years), packages with known vulnerabilities, excessive dependency count, version pinning issues
7. **Configuration Risks** -- Sensitive values in config files, missing environment variable validation, development settings in production configs
8. **Documentation Gaps** -- Missing README sections, undocumented public APIs, stale documentation that contradicts code

Output format:

```markdown
# Concerns Analysis

## Summary
[Overall health assessment: Healthy | Minor Concerns | Significant Debt | Critical Issues]

## Critical Issues (fix immediately)
| # | Issue | Location | Impact | Suggested Fix |
|---|-------|----------|--------|---------------|

## Important Issues (fix soon)
| # | Issue | Location | Impact | Suggested Fix |
|---|-------|----------|--------|---------------|

## Minor Issues (fix when convenient)
| # | Issue | Location | Impact | Suggested Fix |
|---|-------|----------|--------|---------------|

## Technical Debt Inventory
| Category | Count | Severity | Examples |
|----------|-------|----------|----------|

## Security Findings
[Detailed security concerns with specific file:line references]

## Performance Risks
[Detailed performance concerns with specific file:line references]

## Dependency Health
| Package | Issue | Risk Level |
|---------|-------|-----------|

## Recommended Actions (Priority Order)
1. [Highest priority action]
2. [Next priority]
3. ...
```

---

### Step 4: Synthesize Results

After ALL 4 agents have completed, read all 4 output files and create `.titan/research/SUMMARY.md`:

```markdown
# Codebase Scan Summary

## Scan Date: [ISO date]
## Scope: [full codebase | specific directories listed]

## Executive Summary
[5-8 sentences. What kind of project is this? How healthy is it? What are the biggest
opportunities and risks? What should the developer focus on first?]

## Stack at a Glance
[1-paragraph summary from stack.md]

## Architecture at a Glance
[1-paragraph summary from architecture.md]

## Conventions at a Glance
[1-paragraph summary from conventions.md]

## Health Score
| Dimension | Score (1-10) | Key Factor |
|-----------|-------------|------------|
| Code Quality | [N] | [reason] |
| Architecture | [N] | [reason] |
| Security | [N] | [reason] |
| Performance | [N] | [reason] |
| Test Coverage | [N] | [reason] |
| Documentation | [N] | [reason] |
| Dependency Health | [N] | [reason] |
| **Overall** | **[N]** | |

## Top 5 Strengths
1. [strength]
2. ...

## Top 5 Concerns
1. [concern with recommended action]
2. ...

## Recommended TITAN Configuration
- Domain: [recommended domain plugin]
- Focus areas for /titan:plan: [suggested priorities]
- Suggested first phase: [what to tackle first]

## Detailed Reports
- [Stack Analysis](stack.md)
- [Architecture Analysis](architecture.md)
- [Conventions Analysis](conventions.md)
- [Concerns Analysis](concerns.md)
```

### Step 5: Update State and Report

Update `.titan/STATE.md`:

```
- Last Action: Codebase scan completed ([date])
```

Display the summary to the user with the TITAN banner:

```
+==============================================================+
|  ++ TITAN -- SCAN COMPLETE                                   |
+==============================================================+

[Executive summary from SUMMARY.md]

Health Score: [N]/10

Top Strengths:
  * [strength 1]
  * [strength 2]
  * [strength 3]

Top Concerns:
  ! [concern 1]
  ! [concern 2]
  ! [concern 3]

Full reports: .titan/research/

Suggested next step: [recommendation]
```

## Outputs

| File | Content |
|------|---------|
| `.titan/research/stack.md` | Technology stack analysis |
| `.titan/research/architecture.md` | Structural design and data flow |
| `.titan/research/conventions.md` | Coding patterns and conventions |
| `.titan/research/concerns.md` | Technical debt, security, performance |
| `.titan/research/SUMMARY.md` | Synthesized overview with health score |

## State Updates

- `STATE.md` Last Action updated with scan completion timestamp
- If this is the first scan, note it in Knowledge Snapshots

## Error Handling

- **Agent fails to complete:** Report which agent failed, save partial results from completed agents, allow the user to re-run the failed agent individually with: "Re-run the [Stack|Architecture|Conventions|Concerns] researcher"
- **No source files found:** Report the issue. Suggest checking the scan scope or confirming the project has source code.
- **Prior scan exists:** Always archive, never overwrite silently. Inform the user that prior results were archived.

## Context Bracket Behavior

| Bracket | Adaptation |
|---------|------------|
| FRESH | Run all 4 agents with maximum depth. Include optional analyses. |
| MODERATE | Run all 4 agents with standard depth. Skip optional analyses. |
| DEEP | Run only Stack + Concerns agents (highest value). Note skipped agents. |
| CRITICAL | Do NOT run scan. Save state and suggest resuming with fresh context. |

## What's Next

After the scan completes, display:

```
─────────────────────────────────────────────────
★ Recommended: Run /titan:plan to plan the next phase.
  The scan results will inform the planner's decisions.

Other options:
  /titan:learn       — Deep-dive into an unfamiliar technology found in the scan
  /titan:refactor    — Address concerns or tech debt identified in the scan
  /titan:investigate — Research a novel problem the scan uncovered
  /titan:progress    — See full project dashboard and current position
─────────────────────────────────────────────────
```

## Tips

- Run `/titan:scan` before `/titan:plan` on any brownfield project. The research output gives the planner critical context about conventions to follow and risks to avoid.
- After scanning, use `/titan:learn` on any unfamiliar technology found in the stack.
- The Concerns report is excellent input for `/titan:refactor` planning.
- Re-scan after major refactoring to measure improvement in health scores.
- For very large codebases (>100k lines), scope the scan to the most active directories first, then expand.

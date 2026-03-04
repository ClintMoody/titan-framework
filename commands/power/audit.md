---
name: titan:audit
description: Comprehensive security, performance, accessibility, and domain audit
---

# /titan:audit — Multi-Dimensional Quality Audit

> Use to run a comprehensive audit across security, performance, accessibility, and domain-specific dimensions. Can be run anytime — before shipping, after a major feature, or as a periodic health check.

## Prerequisites

- A codebase to audit
- `.titan/` directory recommended (enables domain plugin loading)

## Process

### Step 1 — Configure Audit

Display:
```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — AUDIT                                            ║
╚══════════════════════════════════════════════════════════════╝
```

Ask: **"Which audit dimensions?"** (default: all applicable)

Options:
- ☐ **Security** — OWASP Top 10, dependencies, secrets, headers
- ☐ **Performance** — Bottlenecks, complexity, resource usage
- ☐ **Accessibility** — WCAG compliance (if web/mobile domain)
- ☐ **Domain-Specific** — Checks from loaded domain plugin
- ☐ **Code Quality** — Complexity, duplication, dead code, naming

Default: select all that apply based on domain. Accessibility only for web/mobile.

### Step 2 — Security Audit

Spawn `titan-security` agent (or review in-session for smaller codebases). Check:

**OWASP Top 10:**
1. Injection (SQL, NoSQL, OS command, LDAP)
2. Broken Authentication (weak passwords, session management)
3. Sensitive Data Exposure (plaintext storage, weak encryption)
4. XML External Entities (if applicable)
5. Broken Access Control (privilege escalation, IDOR)
6. Security Misconfiguration (default credentials, verbose errors)
7. XSS (reflected, stored, DOM-based)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging & Monitoring

**Additional checks:**
- Secrets in code (API keys, passwords, tokens in source files or git history)
- Dependency vulnerabilities (check package lock files against known CVEs)
- Security headers (CSP, HSTS, X-Frame-Options — if web)
- Authentication/authorization patterns
- Input validation and sanitization
- CORS configuration

### Step 3 — Performance Audit

Spawn `titan-optimizer` agent (or review in-session). Check:

- **Algorithmic complexity** — O(n²) or worse in hot paths
- **Memory management** — Leaks, unbounded growth, large allocations
- **I/O efficiency** — Unnecessary reads/writes, N+1 queries, missing batching
- **Caching opportunities** — Repeated expensive operations without caching
- **Bundle size** (web) — Unused imports, large dependencies, missing tree-shaking
- **Async operations** — Blocking the main thread, missing parallelization
- **Resource loading** — Lazy loading, code splitting, asset optimization
- **Domain-specific** — Core Web Vitals (web), battery impact (mobile), frame rate (game), etc.

### Step 4 — Accessibility Audit (if web/mobile)

Check:
- Semantic HTML structure
- ARIA labels and roles
- Color contrast ratios
- Keyboard navigation
- Screen reader compatibility
- Focus management
- Alt text for images
- Form labels and error messages

### Step 5 — Domain-Specific Audit

Load checks from `.titan/config.yaml` domain plugin. Execute each domain-specific quality gate.

### Step 6 — Code Quality Audit

Check:
- **Cyclomatic complexity** — Flag functions with complexity > 10
- **Duplication** — Near-identical code blocks
- **Dead code** — Unreachable code, unused exports, unused variables
- **Naming consistency** — Inconsistent naming conventions
- **Error handling** — Swallowed errors, generic catch blocks
- **TODO/FIXME/HACK density** — Flag areas with high concentration

### Step 7 — Compile Report

Write audit report to `.titan/phases/[current]/AUDIT.md` (or `.titan/AUDIT.md` if not in a phase):

```markdown
# TITAN Audit Report

- **Date:** [ISO timestamp]
- **Scope:** [files/modules audited]
- **Dimensions:** [which audits were run]

## Summary
| Dimension | Critical | Important | Minor | Score |
|-----------|----------|-----------|-------|-------|
| Security | X | Y | Z | [A-F] |
| Performance | X | Y | Z | [A-F] |
| Accessibility | X | Y | Z | [A-F] |
| Domain | X | Y | Z | [A-F] |
| Code Quality | X | Y | Z | [A-F] |
| **Overall** | **X** | **Y** | **Z** | **[A-F]** |

## Security Findings
### Critical
- [file:line] — [description] — Fix: [remediation]
### Important
...
### Minor
...

## Performance Findings
...

## Accessibility Findings
...

## Domain Findings
...

## Code Quality Findings
...

## Recommended Actions
1. [Highest priority fix with rationale]
2. [Second priority]
...
```

### Step 8 — Present and Offer Fixes

Present the summary to the user. Offer to fix critical and important issues automatically.

## Outputs

- `AUDIT.md` — Comprehensive audit report
- Optionally: automated fixes for identified issues

## State Updates

- STATE.md: Last Action updated

## Error Handling

- **No source files found:** Ask user to specify paths
- **Unknown domain:** Run all generic checks, skip domain-specific
- **Very large codebase:** Shard the audit by module, report per-module

## Tips

- Run `/titan:audit` before every `/titan:ship` — it catches what `/titan:verify` might miss.
- Security audits are most valuable after adding authentication, payment, or user data features.
- Performance audits are most valuable after the codebase has grown past initial scaffolding.
- Treat the audit score as a compass, not a judgment — it shows where to focus next.

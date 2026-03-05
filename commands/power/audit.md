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

Spawn `titan-security` agent with full scope. The agent runs a 5-phase security scan:

**Phase 1 — Dangerous Code Pattern Scan (Immediate Flags)**
The agent scans all files for 18 high-confidence dangerous patterns including:
- Shell injection (`exec()`, `os.system()`)
- SQL injection (string-concatenated queries)
- Code injection (`eval()`, `new Function()`, `pickle.loads()`)
- XSS (`innerHTML`, `dangerouslySetInnerHTML`, `document.write()`)
- SSRF (`fetch(userProvidedUrl)` server-side)
- CI/CD injection (`${{ github.event.* }}` in workflow `run:` blocks)
- Race conditions (balance checks without database locks)
- Missing auth middleware on routes

**Phase 2 — OWASP Top 10 Systematic Scan**
All 10 categories checked with specific, actionable sub-checks:
- A01: Broken Access Control (IDOR, privilege escalation, path traversal, CORS)
- A02: Cryptographic Failures (weak hashing, hardcoded keys, missing HTTPS)
- A03: Injection (SQL, NoSQL, OS command, LDAP, GraphQL, template)
- A04: Insecure Design (rate limiting, account lockout, CSRF, business logic)
- A05: Security Misconfiguration (defaults, verbose errors, debug mode)
- A06: Vulnerable Components (dependency audit — see tooling below)
- A07: Authentication Failures (sessions, JWT, MFA, credential stuffing)
- A08: Data Integrity Failures (deserialization, CI/CD, unsigned data)
- A09: Logging & Monitoring (PII in logs, missing audit trails)
- A10: SSRF (URL validation, DNS rebinding, cloud metadata access)

**Phase 3 — Secrets Scan**
Searches for hardcoded secrets with known prefix patterns:
- `sk-` (Stripe), `AKIA` (AWS), `ghp_`/`github_pat_` (GitHub), `sk-proj-`/`sk-ant-` (OpenAI/Anthropic)
- `xoxb-`/`xoxp-` (Slack), `SG.` (SendGrid)
- Connection strings with embedded credentials
- Private keys (`.pem`, `-----BEGIN RSA PRIVATE KEY-----`)
- `.env` files in version control

**Phase 4 — Security Headers (Web)**
CSP, HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy.

**Phase 5 — Auth & Authorization Pattern Review**
Token validation on every endpoint, session security (httpOnly, secure, SameSite), consistent authz checks.

**Dependency Audit Tooling:**
Run the appropriate command for the project's ecosystem:

| Ecosystem | Command | Notes |
|-----------|---------|-------|
| Node.js | `npm audit --audit-level=high` | Also check with `npx auditjs` for OSS Index |
| Python | `pip audit` or `safety check` | Install via `pip install pip-audit` |
| Rust | `cargo audit` | Install via `cargo install cargo-audit` |
| Go | `govulncheck ./...` | Install via `go install golang.org/x/vuln/cmd/govulncheck@latest` |
| Ruby | `bundle audit check --update` | Install via `gem install bundler-audit` |
| PHP | `composer audit` | Built-in since Composer 2.4 |

Flag: abandoned/unmaintained dependencies, overly permissive version ranges (`*`, `>=`), dependencies with known CVEs.

**False Positive Awareness:**
The security agent is trained to NOT flag: `.env.example` files, test fixtures, Stripe publishable keys (`pk_test_`, `pk_live_`), SHA256/MD5 for checksums (not passwords), `eval()` in build tools.

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

## Emergency Protocol

If the security audit finds a **CRITICAL** vulnerability in production-facing code:

1. **Stop and alert** — surface it immediately, don't bury it in a report
2. **Show before/after** — provide the exact secure code fix
3. **Verify the fix** — confirm the vulnerability is actually closed
4. **Check for credential exposure** — if secrets were committed to git, they MUST be rotated (removing from code is NOT enough — the secret is in git history)
5. **Document in KNOWLEDGE.md** — prevent recurrence

## Proactive Audit Triggers

Run `/titan:audit` (security dimension at minimum) ALWAYS after:
- New API endpoints added
- Authentication or authorization code changed
- User input handling modified
- Database queries changed
- File upload functionality added
- Payment or financial code written
- External API integrations added
- Dependency updates (`npm update`, `pip install --upgrade`, etc.)
- Webhook handlers added
- GitHub Actions or CI/CD workflow changes

## What's Next

After the audit report is presented, display based on results:

**If critical/important issues were found** (as markdown, NOT in a code block):

---

### ★ Recommended

> **Fix the [X] critical and [Y] important issues.**
> [If fixes were auto-applied: "Review the applied fixes, then continue."]
> [If fixes need manual work: "Address the findings before shipping."]

### Other options

| Command | Action |
|---------|--------|
| `/titan:debug` | Debug a specific issue from the audit |
| `/titan:refactor` | Refactor code flagged for structural issues |
| `/titan:test` | Add tests for areas with low coverage |
| `/titan:08-ship` | Ship (only if all critical issues are resolved) |

---

**If the audit is clean** (as markdown, NOT in a code block):

---

### ★ Recommended

> **Continue with your workflow.**
> [If pre-ship: Run `/titan:08-ship` — your codebase is audit-clean.]
> [If mid-build: Continue `/titan:06-build` for Phase NN.]

### Other options

| Command | Action |
|---------|--------|
| `/titan:08-ship` | Ship the milestone |
| `/titan:07-verify` | Run verification if not done yet |
| `/titan:progress` | See full project dashboard and current position |

---

## Tips

- Run `/titan:audit` before every `/titan:08-ship` — it catches what `/titan:07-verify` might miss.
- Security audits are most valuable after adding authentication, payment, or user data features.
- Performance audits are most valuable after the codebase has grown past initial scaffolding.
- Treat the audit score as a compass, not a judgment — it shows where to focus next.
- When the security agent reports "What Could NOT Be Checked," take those gaps seriously — they represent blind spots.

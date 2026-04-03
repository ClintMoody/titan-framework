---
name: titan:verify-e2e
description: End-to-end verification for features — tests like a user, not a compiler
---

# /titan:verify-e2e — End-to-End Feature Verification

> Use this command to verify features the way a real user would experience them — not just unit tests or type checks, but actual end-to-end behavior validation.

## Prerequisites

- `.titan/MANIFEST.json` exists (run `/titan:03-bootstrap` first).
- `.titan/config.yaml` exists with domain configured.
- At least one feature in MANIFEST.json to verify.

If MANIFEST.json does not exist, print:
```
⚠ No MANIFEST.json found.
  Run /titan:03-bootstrap to generate the feature manifest first.
```
And stop.

## Process

### Step 1: Display Banner

Print this exactly:

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ TITAN — END-TO-END VERIFICATION                          ║
╚══════════════════════════════════════════════════════════════╝

  Testing like a user, not a compiler.
```

### Step 2: Parse Arguments

Accept one of:
- `[feature-id]` — verify a single feature (e.g., `F-001`)
- `--all` — verify all features
- `--passing` — regression test all features currently marked "passing"
- No argument — verify the current feature from LOOP-STATE.json

If no argument and no current feature:
```
⚠ No feature specified and no current feature in LOOP-STATE.json.
  Usage: /titan:verify-e2e F-001
         /titan:verify-e2e --all
         /titan:verify-e2e --passing
```

### Step 3: Load Domain Verification Strategy

Read `.titan/config.yaml` to determine the project domain. Map domain to E2E strategy:

| Domain | Strategy | Tools |
|--------|----------|-------|
| web | Browser automation | Playwright, Cypress, or manual browser checks |
| mobile | Device/emulator testing | Detox, Appium, or manual device checks |
| desktop | Application launch & interaction | Native test frameworks or manual verification |
| audio | Plugin validation & audio pipeline | pluginval, audio file comparison, DAW hosting |
| game | Runtime verification | Game-specific test harness, screenshot comparison |
| data | Pipeline execution & output validation | Run pipeline, validate output schema and values |
| api | HTTP request/response verification | curl, httpie, or API test framework |
| infrastructure | Deploy & validate | terraform plan, dry-run, health checks |
| general | Command execution & output validation | Run commands, check outputs, manual checklist |

### Step 4: Execute Verification for Each Feature

For each feature to verify:

1. **Load feature** from MANIFEST.json — read id, description, acceptance_criteria
2. **Display feature header:**
   ```
   ── F-001: [feature description] ──────────────────────
   ```
3. **For each acceptance criterion:**
   a. Determine the verification approach (automated test, manual check, or inference)
   b. Execute the verification step
   c. Record result: PASS / FAIL / SKIP (with reason)
4. **Feature verdict:** ALL criteria must PASS for the feature to pass

### Step 5: Regression Mode (--all or --passing)

When verifying multiple features:
- Run features in dependency order (features with no dependencies first)
- If a dependency fails, skip dependent features and mark as `SKIP (dependency F-XXX failed)`
- Track cumulative results
- Stop early if `--fail-fast` flag is set

### Step 6: Update MANIFEST.json

For each verified feature:
- If ALL acceptance criteria PASS: set status to `"passing"` (only if previously `"failing"`)
- If ANY criterion FAILS: set status to `"failing"` (even if previously `"passing"` — regression detected)
- If SKIPPED: leave status unchanged

Write updated MANIFEST.json.

### Step 7: Append Results to PROGRESS.md

Add an entry to `.titan/PROGRESS.md`:

```markdown
## E2E Verification — [ISO 8601 timestamp]

| Feature | Status | Criteria Passed | Notes |
|---------|--------|-----------------|-------|
| F-001 | ✓ PASS | 3/3 | |
| F-002 | ✗ FAIL | 1/3 | Criterion 2: [failure detail] |
| F-003 | ○ SKIP | — | Dependency F-002 failed |

**Summary:** [X] passed, [Y] failed, [Z] skipped out of [T] total.
```

### Step 8: Display Results Table

Print (as markdown, NOT in a code block):

---

## ✓ TITAN — E2E VERIFICATION RESULTS

| Feature | Description | Result | Details |
|---------|-------------|--------|---------|
| F-001 | [description] | ✓ PASS | 3/3 criteria |
| F-002 | [description] | ✗ FAIL | 1/3 — [failure summary] |
| F-003 | [description] | ○ SKIP | Dependency failed |

**Overall:** [X]/[T] features passing ([percentage]%)

Progress: ▓▓▓▓▓▓░░░░░░░░░░ [X]/[T] features

---

### ★ Recommended

> [If failures exist: "Fix failing features and re-verify: `/titan:verify-e2e F-XXX`"]
> [If all pass: "All features verified. Continue with `/titan:loop-start` or `/titan:09-ship`."]

### Other options

| Command | Action |
|---------|--------|
| `/titan:verify-e2e --passing` | Regression test all passing features |
| `/titan:debug` | Debug a specific failing feature |
| `/titan:07-build` | Build/fix a failing feature |
| `/titan:loop-start` | Resume autonomous development |

---

## Outputs

| Artifact | Location | Purpose |
|----------|----------|---------|
| MANIFEST.json | `.titan/MANIFEST.json` | Updated feature statuses |
| PROGRESS.md | `.titan/PROGRESS.md` | Verification results appended |

## State Updates

- MANIFEST.json feature statuses updated based on verification results
- PROGRESS.md appended with verification session
- STATE.md Last Action updated

## Error Handling

| Error | Resolution |
|-------|-----------|
| Feature ID not found in MANIFEST | Print available feature IDs, ask user to select |
| E2E test infrastructure not available | Offer to set up basic verification for the domain |
| No automated verification possible | Fall back to manual verification checklist — print each criterion and ask user to confirm |
| Test environment not running | Print setup instructions (e.g., "Start the dev server with `npm run dev`") |
| Flaky test detected (passes sometimes) | Run 3 times, mark as FAIL if any run fails, note flakiness |
| Timeout during verification | Mark as FAIL with timeout note, suggest increasing timeout or optimizing |

## Tips

- E2E verification is the gold standard — it catches integration issues that unit tests miss.
- For web projects, make sure the dev server is running before verification.
- Use `--passing` regularly to catch regressions — features that used to work but broke.
- If automated E2E isn't possible for your domain, the manual checklist mode is still valuable — it enforces structured verification.
- Features are verified against their acceptance criteria in MANIFEST.json — make sure those criteria are specific and testable.

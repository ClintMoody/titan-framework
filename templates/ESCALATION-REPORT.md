# ⚠ TITAN — ESCALATION REPORT

> Loop: {{LOOP_ID}}
> Generated: {{TIMESTAMP}}
> Severity: {{SEVERITY}}

---

## Reason
**Code:** {{ESCALATION_CODE}}
{{ESCALATION_REASON}}

## Affected Feature
- **ID:** {{FEATURE_ID}}
- **Description:** {{FEATURE_DESCRIPTION}}

## Sessions Affected
{{SESSION_LIST}}

## Error Pattern
{{ERROR_PATTERN}}

## What Was Tried
{{ATTEMPTS_LIST}}

## Diagnosis
{{DIAGNOSIS}}

## Recommended Action
{{RECOMMENDED_ACTION}}

## To Resume
```
/titan:loop-start --from {{FEATURE_ID}}
```

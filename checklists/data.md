# Data Domain Checklist
- [ ] Schema validation: all inputs validated against schema before processing, schema versioned
- [ ] Null handling: explicit policy for nulls vs empty vs missing, no silent null coercion
- [ ] Encoding: UTF-8 throughout pipeline, encoding specified in all file I/O and API responses
- [ ] Idempotency: reprocessing the same input produces the same output, deduplication keys defined
- [ ] Backfill strategy: historical data reprocessing documented, can run without affecting live pipeline
- [ ] Retention policy: data lifecycle defined (hot/warm/cold/delete), automated enforcement
- [ ] PII handling: personal data identified, encrypted at rest, access logged, deletion capability verified
- [ ] Audit trail: all data mutations logged with timestamp, actor, before/after values

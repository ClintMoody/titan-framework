# Infrastructure Domain Checklist
- [ ] Health checks: liveness and readiness endpoints, dependencies checked separately
- [ ] Graceful shutdown: in-flight requests complete before exit, shutdown timeout configured
- [ ] Log aggregation: structured logging (JSON), correlation IDs across services, centralized collection
- [ ] Secrets management: no secrets in code or config files, rotatable without redeployment
- [ ] Resource limits: CPU/memory limits set, autoscaling thresholds defined, OOM behavior tested
- [ ] Backup/restore: automated backups scheduled, restore procedure tested, RTO/RPO documented
- [ ] Monitoring alerts: alerts for error rate, latency p99, disk/memory usage, with escalation policy
- [ ] Rollback plan: deployment rollback tested, database migrations reversible, feature flags for instant disable

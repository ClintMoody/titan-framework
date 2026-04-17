# API Domain Checklist
- [ ] Authentication: all endpoints require valid credentials, tokens expire appropriately
- [ ] Rate limiting: per-client limits configured, 429 responses include Retry-After header
- [ ] Versioning: API version in URL or header, deprecation policy documented
- [ ] Error format: consistent error response schema (code, message, details) across all endpoints
- [ ] Pagination: cursor-based or offset pagination on all list endpoints, max page size enforced
- [ ] Input validation: all request bodies validated against schema, reject unknown fields
- [ ] CORS: origins explicitly allowlisted, no wildcard in production
- [ ] Timeouts: request timeouts configured, long operations return 202 with polling endpoint

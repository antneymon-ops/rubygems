# AI Insights Platform — Product Roadmap

## Overview

This roadmap follows a **30 / 60 / 90-day cadence**: MVP → v1 → Enterprise.
Each phase has clear objectives, deliverables, success metrics, and go/no-go gates.

---

## Phase 1 — MVP (Days 0–30)

**Goal**: A working product that real users can sign up for, upload documents, and
query — with basic billing wired up.

### Deliverables

- [ ] `ai_insights` service deployable via Docker Compose
- [ ] `POST /api/v1/ingest` and `POST /api/v1/query` endpoints (live, not stub)
- [ ] `MockProvider` for offline development; `GeminiProvider` for production
- [ ] User registration / login (email + password, JWT)
- [ ] Single-tenant data model: documents, chunks, query_logs
- [ ] Stripe Checkout integration (Free and Pro plans)
- [ ] Usage metering (queries counted per user per month)
- [ ] Basic admin page: user list, document count, query count
- [ ] `GET /health` endpoint + uptime monitoring
- [ ] CI pipeline: lint + unit tests + smoke test on every PR
- [ ] `ai_insights/README.md` with full local-setup instructions
- [ ] Public landing page (can be static HTML)

### Success Metrics

| Metric | Target |
|--------|--------|
| Deployed to staging | Day 14 |
| First end-to-end query (real LLM) | Day 20 |
| 10 beta sign-ups | Day 28 |
| First paid conversion | Day 30 |

### Go / No-Go Gate

- End-to-end query returns cited answer within 5 s on staging
- Stripe webhook processes subscription correctly
- Zero P0 security findings in initial pen-test checklist

---

## Phase 2 — v1 General Availability (Days 31–60)

**Goal**: Multi-tenant platform with team collaboration, polished UX, and production
reliability.

### Deliverables

- [ ] Multi-tenant data model: organizations, memberships, roles (Owner/Admin/Member)
- [ ] Team workspaces: shared notebooks accessible by all org members
- [ ] Invitation flow (email invite → accept → org membership)
- [ ] `GET /api/v1/documents` with pagination and full-text search
- [ ] `DELETE /api/v1/documents/:id` with soft-delete + audit log
- [ ] Streaming responses (Server-Sent Events) for long-running queries
- [ ] Source citation links in query responses
- [ ] Redis-backed rate limiting per tier
- [ ] Webhook support: `document.ingested`, `query.completed` events
- [ ] Prometheus `/metrics` endpoint + Grafana dashboard
- [ ] OpenTelemetry tracing integrated
- [ ] `pgvector` migration for production (replacing SQLite)
- [ ] Staging + production environments on managed container platform
- [ ] Automated nightly backup + monthly restore drill

### Success Metrics

| Metric | Target |
|--------|--------|
| 100 active users | Day 45 |
| NPS first survey | ≥ 40 |
| p95 query latency | ≤ 3 s |
| $5K MRR | Day 60 |

### Go / No-Go Gate

- RBAC prevents cross-tenant data access (validated by security test suite)
- Streaming query works in all major browsers (Chrome, Firefox, Safari)
- Backup restore tested successfully

---

## Phase 3 — Enterprise (Days 61–90)

**Goal**: Close first enterprise deal ($10K+ ACV); achieve SOC 2 Type I readiness.

### Deliverables

- [ ] SSO integration: SAML 2.0 (Okta, Azure AD, Google Workspace)
- [ ] SCIM 2.0 user provisioning
- [ ] Fine-grained RBAC: custom roles, resource-level permissions
- [ ] Audit log API: queryable, exportable, immutable
- [ ] Data retention policy controls (per-org configurable)
- [ ] GDPR/CCPA: data export and deletion endpoints
- [ ] Dedicated deployment option (single-tenant on customer's cloud)
- [ ] SOC 2 Type I evidence collection tooling
- [ ] Enterprise billing: invoiced annually, custom contract support (Stripe Invoicing)
- [ ] SLA dashboard (uptime, p95 latency, incident history) — customer-facing
- [ ] Load tests: stress test at 10× expected peak traffic
- [ ] Security: penetration test (external vendor) + remediation
- [ ] `VertexAiProvider` with Vertex AI RAG Engine (grounding)
- [ ] Localization framework (i18n) for top 5 languages

### Success Metrics

| Metric | Target |
|--------|--------|
| First enterprise pilot signed | Day 75 |
| $15K MRR | Day 90 |
| SOC 2 Type I report initiated | Day 90 |
| < 2 % monthly churn | Day 90 |

### Go / No-Go Gate

- SSO login works end-to-end with at least two identity providers
- Audit logs are tamper-evident (hash chain or append-only store)
- Security pen test findings are remediated or accepted with documented risk

---

## Backlog (Post-90 Days)

| Feature | Priority | Notes |
|---------|----------|-------|
| Mobile app (iOS / Android) | High | React Native shell wrapping web UI |
| Slack / Teams integration | High | Query notebooks from Slack |
| PDF annotation viewer | Medium | Highlight source passages in PDF |
| Fine-tuning on org corpus | Medium | Custom embeddings per enterprise org |
| Marketplace (partner notebooks) | Low | Revenue share with content creators |
| On-premise / air-gapped deploy | Low | For government / high-security customers |

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| Day 0 | Use Sinatra (not Rails) for `ai_insights` service | Minimal footprint; avoid disrupting existing rubygems code |
| Day 0 | SQLite for local dev; PostgreSQL + pgvector for prod | Fast setup locally; scale-out path is clear |
| Day 0 | Vertex AI / Gemini as NotebookLM proxy | NotebookLM API not yet public; Gemini is functionally equivalent |
| Day 0 | Provider adapter pattern | Swap LLM vendors without changing app code |

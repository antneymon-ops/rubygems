# AI Insights Platform — End-to-End Architecture

## Overview

The platform is composed of five logical layers: **Edge**, **Web/API**, **Workers**,
**Data Stores**, and **AI Provider**.  All layers run in containers and are
orchestrated via Docker Compose locally and a managed container platform (Cloud Run /
ECS Fargate) in production.

```
                        ┌─────────────────────────────────────┐
                        │               Clients                │
                        │  Browser  •  CLI  •  Webhook callers │
                        └──────────────────┬──────────────────┘
                                           │ HTTPS
                        ┌──────────────────▼──────────────────┐
                        │          Edge / CDN / WAF            │
                        │   (Cloudflare / Cloud Armor)         │
                        └──────────────────┬──────────────────┘
                                           │
              ┌────────────────────────────┼────────────────────────────┐
              │                            │                            │
   ┌──────────▼──────────┐   ┌─────────────▼─────────────┐  ┌─────────▼────────┐
   │   ai_insights API   │   │   Auth Service (Devise /   │  │  Admin Dashboard  │
   │   (Sinatra/Rack)    │   │   Rodauth + JWT)           │  │  (optional Rails) │
   └──────────┬──────────┘   └─────────────┬─────────────┘  └──────────────────┘
              │                            │
   ┌──────────▼────────────────────────────▼──────┐
   │                  PostgreSQL                   │
   │  tables: tenants, users, documents, chunks,   │
   │          query_logs, billing_events           │
   └──────────┬────────────────────────────────────┘
              │
   ┌──────────▼──────────┐
   │  Job Queue (Redis / │
   │  Sidekiq / Faktory) │
   └──────────┬──────────┘
              │ async jobs
   ┌──────────▼──────────────────────────────────────────────┐
   │                   Worker Service                         │
   │  ingest_worker  •  chunk_worker  •  embed_worker        │
   └──────────┬──────────────────────────────────────────────┘
              │
   ┌──────────▼────────────────────────┐
   │   AI Provider Adapter             │
   │   notebooklm/ interface           │
   │   ├─ gemini_provider.rb (default) │
   │   ├─ vertex_ai_provider.rb        │
   │   └─ mock_provider.rb (test/dev)  │
   └──────────┬────────────────────────┘
              │ HTTPS
   ┌──────────▼────────────────────────┐
   │  Google Vertex AI / Gemini API    │
   │  (or OpenAI-compatible endpoint)  │
   └───────────────────────────────────┘
```

---

## Component Details

### Web / API (`ai_insights/`)

- **Framework**: Sinatra (Rack-compatible, minimal footprint)
- **Auth**: JWT bearer tokens; API keys for machine clients
- **Endpoints**:
  - `POST /api/v1/ingest` — accept document URL or file upload
  - `POST /api/v1/query` — query ingested sources
  - `GET  /api/v1/documents` — list documents for tenant
  - `DELETE /api/v1/documents/:id` — remove document + chunks
- **Rate limiting**: via Rack middleware (Redis-backed token bucket)
- **Versioning**: URL prefix (`/api/v1/`) with `Accept` header fallback

### Workers

| Worker | Trigger | Responsibility |
|--------|---------|----------------|
| `IngestWorker` | `POST /ingest` enqueues | Download/extract raw text from URL or file |
| `ChunkWorker` | after ingest | Split text into overlapping chunks (512 tokens, 64 overlap) |
| `EmbedWorker` | after chunking | Generate embeddings via AI provider; store in `chunks` table |
| `CleanupWorker` | nightly cron | Archive/delete chunks past retention policy |

### Data Stores

| Store | Engine | Purpose |
|-------|--------|---------|
| Primary DB | SQLite (dev) / PostgreSQL (prod) | Relational data: tenants, documents, chunks, logs |
| Vector index | `pgvector` extension on Postgres | Cosine-similarity search over embeddings |
| Object storage | Local filesystem (dev) / S3/GCS (prod) | Raw uploaded files |
| Cache / Queue | Redis | Rate-limit counters, job queues, session cache |

### AI Provider Adapter

The `Notebooklm::Provider` interface (see `ai_insights/lib/notebooklm/`) abstracts
all LLM interactions.  Current implementations:

- **`MockProvider`** — deterministic responses for tests and local dev without
  credentials.
- **`GeminiProvider`** — calls Google Gemini 1.5 Pro via the Vertex AI REST API.
- **`VertexAiProvider`** — alternative Vertex AI endpoint for embedding and RAG.

> **Note on Google NotebookLM API**: As of 2026, Google NotebookLM does not expose a
> public REST API.  The adapter uses Vertex AI (Gemini models + RAG Engine) as the
> functional equivalent.  When Google releases a NotebookLM API, only the provider
> implementation needs to change — the interface contract stays the same.

---

## Observability

| Signal | Tool | Destination |
|--------|------|------------|
| Structured logs | `Logger` (JSON) | stdout → log aggregator (Datadog / Cloud Logging) |
| Metrics | Prometheus `/metrics` endpoint | Prometheus + Grafana |
| Traces | OpenTelemetry SDK | Jaeger (local) / Cloud Trace (prod) |
| Error tracking | Sentry SDK | Sentry project |
| Uptime | HTTP health check `GET /health` | PagerDuty / Alertmanager |

### SLOs

| SLO | Target |
|-----|--------|
| API availability | 99.9 % / month |
| p95 ingest latency | ≤ 10 s (async; time to job enqueue) |
| p95 query latency | ≤ 3 s |
| Embedding pipeline | ≤ 60 s end-to-end |

---

## Security & Compliance

- **Auth**: JWT (HS256, 15-min access / 7-day refresh); API keys hashed with Argon2
- **Secrets**: environment variables; never committed; rotated via secret manager
- **Encryption at rest**: AES-256 (managed by cloud provider KMS)
- **Encryption in transit**: TLS 1.2+ enforced at edge
- **PII handling**: document content is tenant-isolated; no cross-tenant data leakage
- **RBAC**: Owner / Admin / Member roles per organization
- **Audit logs**: every write action logged with actor, timestamp, resource ID
- **SOC 2 Type I** roadmap begins at Month 4 (access control + logging controls)
- **GDPR / CCPA**: data export and deletion APIs included from v1

---

## Disaster Recovery

| Scenario | RPO | RTO | Mechanism |
|----------|-----|-----|-----------|
| Single-AZ failure | 0 | < 5 min | Multi-AZ deployment + auto-failover |
| Database corruption | ≤ 1 h | < 30 min | Point-in-time recovery (PITR) + daily snapshots |
| Full region loss | ≤ 4 h | < 2 h | Snapshot restore to secondary region |
| Accidental deletion | ≤ 24 h | < 1 h | Soft deletes + nightly backup |

Backups are tested monthly via an automated restore game day.

---

## Performance Testing

| Test type | Tool | Frequency | Pass criteria |
|-----------|------|-----------|---------------|
| Smoke | `wrk` or `k6` (10 VU, 30 s) | Every deploy | p95 < 500 ms, 0 errors |
| Baseline | `k6` (50 VU, 5 min) | Weekly | p95 < 1 s, error rate < 0.1 % |
| Stress | `k6` (ramp to 500 VU) | Monthly | No OOM / crash; graceful degradation |
| Soak | `k6` (100 VU, 2 h) | Quarterly | Memory stable; no leak |

Load test scripts live in `ai_insights/load_tests/`.

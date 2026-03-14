# AI Insights Service

A monetizable, multi-tenant AI knowledge platform that lets teams upload documents
and query them with natural language — powered by Google Gemini / Vertex AI and
inspired by Google NotebookLM.

---

## Quick Start (Local Development)

### Prerequisites

- Ruby ≥ 3.1
- Bundler (`gem install bundler`)
- [Docker + Docker Compose](https://docs.docker.com/compose/) *(optional)*

### 1 — Install dependencies

```bash
cd ai_insights
bundle install
```

### 2 — Run the service

```bash
# Uses MockProvider by default (no credentials needed)
bundle exec rackup config.ru -p 3001
```

The service starts at `http://localhost:3001`.

### 3 — Try it out

```bash
# Health check
curl http://localhost:3001/health

# Ingest a document
curl -X POST http://localhost:3001/api/v1/ingest \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com/docs/intro.txt","title":"Intro"}'

# Query ingested documents
curl -X POST http://localhost:3001/api/v1/query \
  -H "Content-Type: application/json" \
  -d '{"query":"What is the main topic?","document_ids":[1]}'
```

---

## Running with Docker Compose

```bash
# From the repository root
docker compose up ai_insights
```

This starts the service on port 3001 with a SQLite database volume.

---

## Configuration

All configuration is via environment variables.

| Variable | Default | Description |
|----------|---------|-------------|
| `AI_PROVIDER` | `mock` | `mock`, `gemini` |
| `DATABASE_URL` | `sqlite://db/development.sqlite3` | Sequel-compatible DB URL |
| `GOOGLE_API_KEY` | *(required for gemini)* | Gemini Developer API key |
| `GOOGLE_PROJECT_ID` | *(required for vertex_ai)* | GCP project ID |
| `GOOGLE_LOCATION` | `us-central1` | Vertex AI region |
| `VERTEX_AI_MODEL` | `gemini-1.5-pro` | Gemini model name |
| `EMBEDDING_MODEL` | `text-embedding-004` | Embedding model name |
| `PORT` | `3001` | HTTP port (when using Puma) |

### Using the Gemini provider

```bash
export AI_PROVIDER=gemini
export GOOGLE_API_KEY=your_api_key_here
bundle exec rackup config.ru -p 3001
```

Obtain a Gemini API key at <https://aistudio.google.com/app/apikey>.

---

## Running Tests

```bash
cd ai_insights
bundle install
bundle exec rake spec
```

All tests use `MockProvider` and an in-memory SQLite database.  No credentials
are required to run the test suite.

---

## NotebookLM Integration

See `lib/notebooklm/` for the provider interface and implementations.

| File | Purpose |
|------|---------|
| `provider.rb` | Abstract interface + environment variable docs |
| `mock_provider.rb` | Deterministic stub (dev/test) |
| `gemini_provider.rb` | Google Gemini via Generative Language API |

### Why Vertex AI / Gemini instead of NotebookLM directly?

Google NotebookLM does not expose a public REST API as of 2026.  Vertex AI's
Gemini models provide equivalent capabilities:

- Document chunking and embedding generation
- Grounded generation with source citations
- Multilingual question answering

When Google publishes a NotebookLM API, only the provider implementation changes.
The `Provider` interface and all application code remain stable.

---

## Project Structure

```
ai_insights/
├── app.rb                        # Sinatra application
├── config.ru                     # Rack entrypoint
├── Gemfile                       # Ruby dependencies
├── Rakefile                      # rake spec
├── README.md                     # This file
├── db/
│   ├── migrations/
│   │   └── 001_create_initial_schema.rb
│   └── development.sqlite3       # auto-created on first run
├── lib/
│   ├── database.rb               # Sequel connection + migrations
│   └── notebooklm/
│       ├── provider.rb           # Abstract provider interface
│       ├── mock_provider.rb      # Stub for dev/test
│       └── gemini_provider.rb    # Google Gemini adapter
└── spec/
    ├── spec_helper.rb
    ├── endpoints_spec.rb         # API endpoint tests
    └── provider_spec.rb          # Provider adapter tests
```

---

## API Reference

### `GET /health`
Returns service health.

**Response**
```json
{ "status": "ok", "timestamp": "2026-03-14T13:00:00Z" }
```

---

### `POST /api/v1/ingest`
Ingest a document by URL.

**Request body**
```json
{ "url": "https://example.com/document.pdf", "title": "Optional title" }
```

**Response** `202 Accepted`
```json
{ "document_id": 1, "status": "ingested", "message": "Ingestion queued" }
```

---

### `POST /api/v1/query`
Query ingested documents.

**Request body**
```json
{ "query": "What are the key findings?", "document_ids": [1, 2] }
```

**Response** `200 OK`
```json
{
  "answer": "The key findings are ...",
  "citations": [
    { "document_id": 1, "passage": "...", "score": 0.97 }
  ],
  "model": "gemini-1.5-pro"
}
```

---

## Roadmap

See [`../docs/ROADMAP.md`](../docs/ROADMAP.md) for the full 30/60/90-day plan.

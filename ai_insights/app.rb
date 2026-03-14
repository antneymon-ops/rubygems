# frozen_string_literal: true

require "sinatra"
require "sinatra/json"
require "json"

require_relative "lib/database"
require_relative "lib/notebooklm/provider"
require_relative "lib/notebooklm/mock_provider"
require_relative "lib/notebooklm/gemini_provider"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

configure do
  set :show_exceptions, false

  provider_name = ENV.fetch("AI_PROVIDER", "mock")
  provider = case provider_name
  when "gemini"  then Notebooklm::GeminiProvider.new
  when "mock"    then Notebooklm::MockProvider.new
  else raise ArgumentError, "Unknown AI_PROVIDER: #{provider_name}"
  end

  set :ai_provider, provider
end

configure :test do
  set :ai_provider, Notebooklm::MockProvider.new
end

# ---------------------------------------------------------------------------
# Health
# ---------------------------------------------------------------------------

get "/health" do
  json status: "ok", timestamp: Time.now.utc.iso8601
end

# ---------------------------------------------------------------------------
# Ingest endpoint
# POST /api/v1/ingest
# Body: { "url": "https://...", "title": "optional title" }
#   OR multipart file upload with field "file"
# ---------------------------------------------------------------------------

post "/api/v1/ingest" do
  request.body.rewind
  body_str = request.body.read
  params_json = body_str.empty? ? {} : JSON.parse(body_str)

  url   = params_json["url"]
  title = params_json["title"] || url

  halt 422, json(error: "url is required") if url.nil? || url.strip.empty?

  doc_id = Database.db[:documents].insert(
    url:        url.strip,
    title:      title.to_s.strip,
    status:     "pending",
    created_at: Time.now.utc
  )
  doc = { id: doc_id }

  # In production this would be enqueued to a background worker.
  # For the stub we run inline processing synchronously.
  result = settings.ai_provider.ingest(url: url.strip, title: title.to_s.strip)

  Database.db[:documents].where(id: doc[:id]).update(
    status:     result[:status],
    chunk_count: result[:chunk_count],
    updated_at: Time.now.utc
  )

  status 202
  json document_id: doc[:id], status: result[:status], message: "Ingestion queued"
rescue JSON::ParserError
  halt 400, json(error: "Invalid JSON body")
end

# ---------------------------------------------------------------------------
# Query endpoint
# POST /api/v1/query
# Body: { "query": "What is ...", "document_ids": [1, 2] }
# ---------------------------------------------------------------------------

post "/api/v1/query" do
  request.body.rewind
  body_str = request.body.read
  params_json = body_str.empty? ? {} : JSON.parse(body_str)

  query_text   = params_json["query"]
  document_ids = Array(params_json["document_ids"])

  halt 422, json(error: "query is required") if query_text.nil? || query_text.strip.empty?

  result = settings.ai_provider.query(
    query:        query_text.strip,
    document_ids: document_ids
  )

  Database.db[:query_logs].insert(
    query_text:   query_text.strip,
    answer:       result[:answer],
    document_ids: document_ids.join(","),
    created_at:   Time.now.utc
  )

  json answer: result[:answer], citations: result[:citations], model: result[:model]
rescue JSON::ParserError
  halt 400, json(error: "Invalid JSON body")
end

# ---------------------------------------------------------------------------
# Error handling
# ---------------------------------------------------------------------------

error 404 do
  json error: "Not found"
end

error 500 do
  json error: "Internal server error"
end

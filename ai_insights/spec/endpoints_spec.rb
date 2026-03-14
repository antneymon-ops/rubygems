# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "Health endpoint" do
  it "returns 200 with ok status" do
    get "/health"
    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body["status"]).to eq("ok")
    expect(body["timestamp"]).to match(/\d{4}-\d{2}-\d{2}T/)
  end
end

RSpec.describe "POST /api/v1/ingest" do
  let(:valid_payload) { { url: "https://example.com/doc.txt", title: "Test Doc" }.to_json }
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  it "returns 202 with document_id for a valid URL" do
    post "/api/v1/ingest", valid_payload, headers
    expect(last_response.status).to eq(202)
    body = JSON.parse(last_response.body)
    expect(body["document_id"]).to be_a(Integer)
    expect(body["status"]).to eq("ingested")
  end

  it "returns 422 when url is missing" do
    post "/api/v1/ingest", {}.to_json, headers
    expect(last_response.status).to eq(422)
    body = JSON.parse(last_response.body)
    expect(body["error"]).to match(/url is required/i)
  end

  it "returns 422 when url is blank" do
    post "/api/v1/ingest", { url: "   " }.to_json, headers
    expect(last_response.status).to eq(422)
  end

  it "returns 400 on malformed JSON" do
    post "/api/v1/ingest", "not json{{{", headers
    expect(last_response.status).to eq(400)
  end

  it "persists the document in the database" do
    post "/api/v1/ingest", valid_payload, headers
    expect(last_response.status).to eq(202)
    doc = Database.db[:documents].first
    expect(doc[:url]).to eq("https://example.com/doc.txt")
    expect(doc[:title]).to eq("Test Doc")
    expect(doc[:status]).to eq("ingested")
  end
end

RSpec.describe "POST /api/v1/query" do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  before do
    # Seed a document so document_ids can reference real IDs
    Database.db[:documents].insert(
      url: "https://example.com/doc.txt", title: "Seed", status: "ingested",
      chunk_count: 3, created_at: Time.now.utc
    )
  end

  it "returns 200 with answer and citations for a valid query" do
    doc_id = Database.db[:documents].first[:id]
    post "/api/v1/query", { query: "What is RubyGems?", document_ids: [doc_id] }.to_json, headers
    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body["answer"]).to be_a(String)
    expect(body["citations"]).to be_an(Array)
    expect(body["model"]).to eq("mock-provider-v1")
  end

  it "returns 422 when query is missing" do
    post "/api/v1/query", { document_ids: [] }.to_json, headers
    expect(last_response.status).to eq(422)
    body = JSON.parse(last_response.body)
    expect(body["error"]).to match(/query is required/i)
  end

  it "returns 422 when query is blank" do
    post "/api/v1/query", { query: "" }.to_json, headers
    expect(last_response.status).to eq(422)
  end

  it "returns 400 on malformed JSON" do
    post "/api/v1/query", ":::bad", headers
    expect(last_response.status).to eq(400)
  end

  it "persists the query log" do
    post "/api/v1/query", { query: "Hello?" }.to_json, headers
    expect(last_response.status).to eq(200)
    log = Database.db[:query_logs].first
    expect(log[:query_text]).to eq("Hello?")
    expect(log[:answer]).to be_a(String)
  end
end

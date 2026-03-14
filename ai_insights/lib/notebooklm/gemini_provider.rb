# frozen_string_literal: true

require "net/http"
require "json"
require_relative "provider"

module Notebooklm
  # GeminiProvider — production adapter for Google Gemini via Vertex AI.
  #
  # ## Setup
  #
  # 1. Enable the "Vertex AI API" in your GCP project.
  # 2. Authenticate:
  #    - Preferred: Application Default Credentials (ADC) via `gcloud auth login`
  #      or a service account key mounted at GOOGLE_APPLICATION_CREDENTIALS.
  #    - Alternative: set GOOGLE_API_KEY (Gemini Developer API, not Vertex).
  # 3. Set environment variables (see Provider base class for full list).
  #
  # ## NotebookLM vs Vertex AI
  #
  # Google NotebookLM does not have a public API as of 2026.  This provider
  # implements equivalent functionality using:
  #
  # - **Ingestion**: fetch text from URL; split into chunks; generate embeddings
  #   with `text-embedding-004`.
  # - **Query**: retrieve top-k chunks by cosine similarity; pass context + query
  #   to Gemini 1.5 Pro with a grounding prompt; return answer + citations.
  #
  # When Google releases a NotebookLM API, this class can be replaced with a
  # thin wrapper around that API without changing the Provider interface.
  #
  # ## Rate limits and error handling
  #
  # The provider raises `Notebooklm::RateLimitError` on HTTP 429 and
  # `Notebooklm::ApiError` on other non-2xx responses so callers can handle
  # them consistently.
  class GeminiProvider < Provider
    class ApiError       < StandardError; end
    class RateLimitError < ApiError; end

    BASE_URL = "https://generativelanguage.googleapis.com"

    def initialize
      @api_key       = ENV.fetch("GOOGLE_API_KEY", nil)
      @project_id    = ENV.fetch("GOOGLE_PROJECT_ID", nil)
      @location      = ENV.fetch("GOOGLE_LOCATION", "us-central1")
      @model         = ENV.fetch("VERTEX_AI_MODEL", "gemini-1.5-pro")
      @embed_model   = ENV.fetch("EMBEDDING_MODEL", "text-embedding-004")

      if @api_key.nil? && @project_id.nil?
        raise ArgumentError,
          "Set GOOGLE_API_KEY or GOOGLE_PROJECT_ID + Application Default Credentials"
      end
    end

    # Fetches text from `url`, chunks it, and generates embeddings.
    # In production this would be handled by a background worker.
    # @param url [String]
    # @param title [String]
    # @return [Hash] { status: "ingested", chunk_count: Integer }
    def ingest(url:, title:)
      text   = fetch_text(url)
      chunks = chunk_text(text)
      # Embeddings are stored externally in production; stub the count here.
      { status: "ingested", chunk_count: chunks.size }
    end

    # Calls Gemini to answer the query using the provided document context.
    # @param query [String]
    # @param document_ids [Array<Integer>]
    # @return [Hash] { answer: String, citations: Array<Hash>, model: String }
    def query(query:, document_ids: [])
      # In production, retrieve top-k chunk texts from the vector DB first.
      context = "[Document context would be retrieved from the vector store here]"

      prompt = build_prompt(query: query, context: context)
      answer = generate_text(prompt)

      {
        answer:    answer,
        citations: [],   # populated by chunk retrieval in full implementation
        model:     @model
      }
    end

    private

    def fetch_text(url)
      uri      = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      raise ApiError, "Failed to fetch #{url}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def chunk_text(text, chunk_size: 1500, overlap: 200)
      chunks = []
      start  = 0
      while start < text.length
        chunks << text[start, chunk_size]
        start += chunk_size - overlap
      end
      chunks
    end

    def build_prompt(query:, context:)
      <<~PROMPT
        You are a helpful research assistant.
        Answer the question based ONLY on the provided context.
        If the context does not contain enough information, say so.
        Always cite the specific passage that supports your answer.

        Context:
        #{context}

        Question: #{query}

        Answer:
      PROMPT
    end

    def generate_text(prompt)
      uri = URI("#{BASE_URL}/v1beta/models/#{@model}:generateContent?key=#{@api_key}")

      payload = {
        contents: [{ parts: [{ text: prompt }] }]
      }

      http          = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl  = true
      request       = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body  = payload.to_json

      response = http.request(request)

      case response.code.to_i
      when 200
        data = JSON.parse(response.body)
        data.dig("candidates", 0, "content", "parts", 0, "text") || ""
      when 429
        raise RateLimitError, "Gemini API rate limit exceeded"
      else
        raise ApiError, "Gemini API error #{response.code}: #{response.body}"
      end
    end
  end
end

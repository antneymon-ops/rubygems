# frozen_string_literal: true

module Notebooklm
  # Provider — abstract interface for all NotebookLM / LLM adapters.
  #
  # Every concrete provider **must** implement:
  #
  #   #ingest(url:, title:) -> Hash
  #     Accepts a document URL and an optional title.
  #     Returns: { status: String, chunk_count: Integer }
  #
  #   #query(query:, document_ids:) -> Hash
  #     Accepts a natural-language query and an optional array of document IDs
  #     to restrict retrieval scope.
  #     Returns: { answer: String, citations: Array<Hash>, model: String }
  #
  # ## Why "notebooklm"?
  #
  # Google NotebookLM is the product inspiration for this platform.  As of 2026
  # Google has not released a public NotebookLM API.  The recommended alternative
  # is the **Vertex AI Gemini API** (specifically the grounded generation feature
  # of Vertex AI RAG Engine), which provides functionally equivalent capabilities:
  #
  # - Document ingestion and chunking
  # - Embedding generation (text-embedding-004 or text-multilingual-embedding-002)
  # - Grounded generation with source citations (Gemini 1.5 Pro)
  #
  # When Google publishes a NotebookLM API, only the provider implementation needs
  # to change.  The interface contract and the rest of the application remain stable.
  #
  # ## Environment variables (shared across providers)
  #
  #   AI_PROVIDER          mock | gemini | vertex_ai (default: mock)
  #   GOOGLE_PROJECT_ID    GCP project ID (required for gemini / vertex_ai)
  #   GOOGLE_LOCATION      Vertex AI region, e.g. us-central1 (default: us-central1)
  #   GOOGLE_API_KEY       API key for Gemini Developer API (optional; prefer ADC)
  #   VERTEX_AI_MODEL      Gemini model name (default: gemini-1.5-pro)
  #   EMBEDDING_MODEL      Embedding model (default: text-embedding-004)
  #
  class Provider
    # @param url [String] publicly reachable document URL
    # @param title [String] human-readable label stored with the document
    # @return [Hash] { status: String, chunk_count: Integer }
    def ingest(url:, title:)
      raise NotImplementedError, "#{self.class}#ingest is not implemented"
    end

    # @param query [String] natural-language question
    # @param document_ids [Array<Integer>] optional scope; empty means all docs
    # @return [Hash] { answer: String, citations: Array<Hash>, model: String }
    def query(query:, document_ids: [])
      raise NotImplementedError, "#{self.class}#query is not implemented"
    end
  end
end

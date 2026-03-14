# frozen_string_literal: true

require_relative "provider"

module Notebooklm
  # MockProvider — deterministic stub for local development and tests.
  #
  # Requires no credentials and produces predictable responses, making it
  # suitable for CI, unit tests, and offline development.
  #
  # All responses are hard-coded and do not perform any network requests.
  class MockProvider < Provider
    MOCK_ANSWER = "This is a mock answer. Configure AI_PROVIDER=gemini for real responses."
    MOCK_MODEL  = "mock-provider-v1"

    # Simulates ingesting a document.
    # @param url [String]
    # @param title [String]
    # @return [Hash] { status: "ingested", chunk_count: Integer }
    def ingest(url:, title:)
      {
        status:      "ingested",
        chunk_count: rand(5..20)
      }
    end

    # Returns a canned answer with a single stub citation.
    # @param query [String]
    # @param document_ids [Array<Integer>]
    # @return [Hash]
    def query(query:, document_ids: [])
      {
        answer:    "#{MOCK_ANSWER} (query: #{query.slice(0, 50)})",
        citations: [{ document_id: document_ids.first || 0, passage: "Mock passage text.", score: 0.99 }],
        model:     MOCK_MODEL
      }
    end
  end
end

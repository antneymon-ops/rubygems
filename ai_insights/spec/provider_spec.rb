# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../lib/notebooklm/mock_provider"
require_relative "../lib/notebooklm/gemini_provider"

RSpec.describe Notebooklm::MockProvider do
  subject(:provider) { described_class.new }

  describe "#ingest" do
    it "returns a hash with status 'ingested'" do
      result = provider.ingest(url: "https://example.com", title: "Test")
      expect(result[:status]).to eq("ingested")
      expect(result[:chunk_count]).to be_a(Integer).and be_positive
    end
  end

  describe "#query" do
    it "returns answer, citations, and model" do
      result = provider.query(query: "What is this?", document_ids: [1])
      expect(result[:answer]).to be_a(String).and include("mock")
      expect(result[:citations]).to be_an(Array)
      expect(result[:model]).to eq("mock-provider-v1")
    end

    it "includes the query text in the answer" do
      result = provider.query(query: "unique query text", document_ids: [])
      expect(result[:answer]).to include("unique query text")
    end

    it "works with no document_ids" do
      result = provider.query(query: "anything", document_ids: [])
      expect(result[:answer]).to be_a(String)
    end
  end
end

RSpec.describe Notebooklm::Provider do
  subject(:provider) { described_class.new }

  describe "#ingest" do
    it "raises NotImplementedError" do
      expect { provider.ingest(url: "https://example.com", title: "t") }
        .to raise_error(NotImplementedError)
    end
  end

  describe "#query" do
    it "raises NotImplementedError" do
      expect { provider.query(query: "test", document_ids: []) }
        .to raise_error(NotImplementedError)
    end
  end
end

RSpec.describe Notebooklm::GeminiProvider do
  describe ".new" do
    it "raises ArgumentError when no credentials are configured" do
      with_env("GOOGLE_API_KEY" => nil, "GOOGLE_PROJECT_ID" => nil) do
        expect { described_class.new }.to raise_error(ArgumentError, /GOOGLE_API_KEY/)
      end
    end

    it "initializes successfully with GOOGLE_API_KEY set" do
      with_env("GOOGLE_API_KEY" => "test-key-12345") do
        expect { described_class.new }.not_to raise_error
      end
    end
  end

  # Helper to temporarily set/unset environment variables in tests
  def with_env(overrides)
    originals = {}
    overrides.each do |key, value|
      originals[key] = ENV[key]
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
    yield
  ensure
    originals.each do |key, original|
      if original.nil?
        ENV.delete(key)
      else
        ENV[key] = original
      end
    end
  end
end

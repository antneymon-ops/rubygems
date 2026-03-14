# frozen_string_literal: true

ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://"  # in-memory SQLite; fresh DB per connection reset

require "rack/test"
require_relative "../app"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    # Reset DB connection so migrations re-run on a fresh in-memory DB
    Database.reset!
    # Force the DB to reconnect and apply migrations
    Database.db
  end

  config.after(:suite) do
    Database.reset!
  end

  def app
    Sinatra::Application
  end
end

# frozen_string_literal: true

require "sequel"

module Database
  DB_PATH = ENV.fetch("DATABASE_URL", "sqlite://#{File.expand_path("../db/development.sqlite3", __dir__)}")

  def self.db
    @db ||= connect_and_migrate
  end

  def self.reset!
    @db&.disconnect
    @db = nil
  end

  def self.connect_and_migrate
    db = Sequel.connect(DB_PATH)
    Sequel.extension :migration
    Sequel::Migrator.run(db, File.expand_path("../db/migrations", __dir__))
    db
  end
  private_class_method :connect_and_migrate
end

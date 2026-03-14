# frozen_string_literal: true

require_relative "helper"
require "rubygems/user_download_schema"

class TestGemUserDownloadSchema < Gem::TestCase
  def setup
    super
  end

  # --- Gem::UserDownloadSchema ---

  def test_initialize_defaults
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")

    assert_equal "my_gem",  schema.gem_name
    assert_equal "1.0.0",   schema.version
    assert_equal "alice",   schema.author
    assert_equal "ruby",    schema.platform  # Gem::Platform::RUBY.to_s == "ruby"
    assert_nil              schema.downloaded_at
    assert_equal false,     schema.success
  end

  def test_initialize_with_platform
    schema = Gem::UserDownloadSchema.new(
      gem_name: "my_gem",
      version: "2.0.0",
      author: "bob",
      platform: "x86_64-linux"
    )

    assert_equal "x86_64-linux", schema.platform
  end

  def test_initialize_with_success_true
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice", success: true)

    assert schema.success
  end

  def test_mark_success_sets_success_true
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")

    refute schema.success
    schema.mark_success!
    assert schema.success
  end

  def test_mark_success_sets_downloaded_at
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")

    assert_nil schema.downloaded_at
    schema.mark_success!
    refute_nil schema.downloaded_at
    assert_kind_of Time, schema.downloaded_at
  end

  def test_mark_success_returns_self
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")

    assert_same schema, schema.mark_success!
  end

  def test_to_h
    schema = Gem::UserDownloadSchema.new(
      gem_name: "my_gem",
      version: "1.0.0",
      author: "alice",
      platform: "ruby"
    )
    schema.mark_success!

    h = schema.to_h

    assert_equal "my_gem", h[:gem_name]
    assert_equal "1.0.0",  h[:version]
    assert_equal "alice",  h[:author]
    assert_equal "ruby",   h[:platform]
    assert_equal true,     h[:success]
    assert_kind_of Time,   h[:downloaded_at]
  end

  def test_to_h_without_download
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")

    h = schema.to_h

    assert_equal false, h[:success]
    assert_nil          h[:downloaded_at]
  end

  # --- Gem::UserDownloadSchema::Stats ---

  def test_stats_initial_state
    stats = Gem::UserDownloadSchema::Stats.new

    assert_equal 0,   stats.total
    assert_equal 0,   stats.successful
    assert_equal 0,   stats.failed
    assert_equal 0.0, stats.success_rate
  end

  def test_stats_record_success
    stats  = Gem::UserDownloadSchema::Stats.new
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")
    schema.mark_success!

    stats.record(schema)

    assert_equal 1,     stats.total
    assert_equal 1,     stats.successful
    assert_equal 0,     stats.failed
    assert_equal 100.0, stats.success_rate
  end

  def test_stats_record_failure
    stats  = Gem::UserDownloadSchema::Stats.new
    schema = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")

    stats.record(schema)

    assert_equal 1,   stats.total
    assert_equal 0,   stats.successful
    assert_equal 1,   stats.failed
    assert_equal 0.0, stats.success_rate
  end

  def test_stats_success_rate_mixed
    stats = Gem::UserDownloadSchema::Stats.new

    ok = Gem::UserDownloadSchema.new(gem_name: "a", version: "1.0.0", author: "alice")
    ok.mark_success!
    fail1 = Gem::UserDownloadSchema.new(gem_name: "b", version: "1.0.0", author: "bob")
    fail2 = Gem::UserDownloadSchema.new(gem_name: "c", version: "1.0.0", author: "carol")

    [ok, fail1, fail2].each {|r| stats.record(r) }

    assert_equal 3,     stats.total
    assert_equal 1,     stats.successful
    assert_equal 2,     stats.failed
    assert_equal 33.33, stats.success_rate
  end

  def test_stats_display
    stats = Gem::UserDownloadSchema::Stats.new

    ok = Gem::UserDownloadSchema.new(gem_name: "a", version: "1.0.0", author: "alice")
    ok.mark_success!
    fail1 = Gem::UserDownloadSchema.new(gem_name: "b", version: "1.0.0", author: "bob")

    stats.record(ok)
    stats.record(fail1)

    output = capture_output { stats.display }.first

    assert_includes output, "=== Download Statistics ==="
    assert_includes output, "Total Downloads"
    assert_includes output, "2"
    assert_includes output, "Successful"
    assert_includes output, "1"
    assert_includes output, "Failed"
    assert_includes output, "Success Rate"
    assert_includes output, "50.00%"
  end
end

# frozen_string_literal: true

##
# Gem::UserDownloadSchema provides a schema for recording gems that a user
# has created and subsequently downloaded. Each record captures the gem's
# identity, platform, authorship and whether the download succeeded.
#
# A companion Stats class aggregates multiple records and reports success
# rate, giving a quantitative view of the platform's reliability for a
# user's created gems.
#
# Example usage:
#
#   record = Gem::UserDownloadSchema.new(gem_name: "my_gem", version: "1.0.0", author: "alice")
#   record.mark_success!
#
#   stats = Gem::UserDownloadSchema::Stats.new
#   stats.record(record)
#   stats.display

class Gem::UserDownloadSchema
  ##
  # The name of the gem.
  attr_reader :gem_name

  ##
  # The version string of the gem.
  attr_reader :version

  ##
  # The author (creator) of the gem.
  attr_reader :author

  ##
  # The platform the gem was downloaded for (defaults to +Gem::Platform::RUBY+).
  # Always stored as a String for consistency.
  attr_reader :platform

  ##
  # The time at which the download was recorded.
  attr_reader :downloaded_at

  ##
  # Whether the download completed successfully.
  attr_reader :success

  ##
  # Creates a new download record.
  #
  # +gem_name+  - name of the gem (required)
  # +version+   - version string (required)
  # +author+    - creator of the gem (required)
  # +platform+  - target platform (default: Gem::Platform::RUBY)
  # +success+   - initial success state (default: false)

  def initialize(gem_name:, version:, author:, platform: Gem::Platform::RUBY, success: false)
    @gem_name = gem_name
    @version = version
    @author = author
    @platform = platform.to_s
    @downloaded_at = nil
    @success = success
  end

  ##
  # Marks this download as successful and records the current time.
  # Returns +self+ to allow chaining.

  def mark_success!
    @success = true
    @downloaded_at = Time.now
    self
  end

  ##
  # Returns a Hash representation of this record.

  def to_h
    {
      gem_name: @gem_name,
      version: @version,
      author: @author,
      platform: @platform,
      downloaded_at: @downloaded_at,
      success: @success,
    }
  end

  ##
  # Gem::UserDownloadSchema::Stats aggregates a collection of
  # UserDownloadSchema records and provides summary statistics that
  # indicate the platform's download reliability for user-created gems.

  class Stats
    def initialize
      @records = []
    end

    ##
    # Adds a UserDownloadSchema +record+ to the collection.

    def record(download_schema)
      @records << download_schema
    end

    ##
    # Total number of download records.

    def total
      @records.size
    end

    ##
    # Number of successful downloads.

    def successful
      @records.count(&:success)
    end

    ##
    # Number of failed downloads.

    def failed
      total - successful
    end

    ##
    # Download success rate as a percentage (0.0–100.0).
    # Returns 0.0 when no records have been added yet.

    def success_rate
      return 0.0 if total.zero?

      (successful.to_f / total * 100).round(2)
    end

    PATTERN = "%22s: %s\n" # :nodoc:

    ##
    # Prints a formatted statistics summary to +$stdout+.

    def display
      $stdout.puts "=== Download Statistics ==="
      $stdout.printf PATTERN, "Total Downloads", total
      $stdout.printf PATTERN, "Successful", successful
      $stdout.printf PATTERN, "Failed", failed
      $stdout.printf PATTERN, "Success Rate", format("%.2f%%", success_rate)
    end
  end
end

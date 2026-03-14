# frozen_string_literal: true

require_relative "../command"
require_relative "../gemcutter_utilities"

class Gem::Commands::SigninCommand < Gem::Command
  include Gem::GemcutterUtilities

  def initialize
    super "signin", "Sign in to any gemcutter-compatible host. "\
          "It defaults to https://rubygems.org"

    add_option("--host HOST", "Push to another gemcutter-compatible host") do |value, options|
      options[:host] = value
    end

    add_otp_option
  end

  def description # :nodoc:
    <<-EOF
The signin command executes host sign in for a push server (the default is
https://rubygems.org). The host can be provided with the host flag or can
be inferred from the provided gem. Host resolution matches the resolution
strategy for the push command.

On successful sign in, an API key is created and stored in the credentials
file at the path shown by `gem environment credentials`. The credentials
file uses YAML format. The API key is used to authenticate subsequent gem
push, yank and owner management operations.

You can customize the name and access scopes of the API key during sign in.
Available scopes are: #{(Gem::GemcutterUtilities::API_SCOPES + Gem::GemcutterUtilities::EXCLUSIVELY_API_SCOPES).map(&:to_s).join(", ")}.

If multi-factor authentication (MFA) is enabled on your account, you will be
prompted to provide a one-time password (OTP) code, or to authenticate via
a WebAuthn security device. You can also provide the OTP code using the
--otp option or the GEM_HOST_OTP_CODE environment variable.

To sign in non-interactively, set the GEM_HOST_API_KEY environment variable
to an existing API key instead of using this command.
    EOF
  end

  def usage # :nodoc:
    program_name
  end

  def execute
    sign_in options[:host]
  end
end

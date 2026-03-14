# frozen_string_literal: true

##
# A collection of text-wrangling methods

module Gem::Text
  ##
  # Remove any non-printable characters and make the text suitable for
  # printing.
  def clean_text(text)
    text.gsub(/[\000-\b\v-\f\016-\037\177]/, ".")
  end

  def truncate_text(text, description, max_length = 100_000)
    raise ArgumentError, "max_length must be positive" unless max_length > 0
    return text if text.size <= max_length
    "Truncating #{description} to #{max_length.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse} characters:\n" + text[0, max_length]
  end

  ##
  # Wraps +text+ to +wrap+ characters and optionally indents by +indent+
  # characters

  def format_text(text, wrap, indent = 0)
    result = []
    work = clean_text(text)

    while work.length > wrap do
      if work =~ /^(.{0,#{wrap}})[ \n]/
        result << $1.rstrip
        work.slice!(0, $&.length)
      else
        result << work.slice!(0, wrap)
      end
    end

    result << work if work.length.nonzero?
    result.join("\n").gsub(/^/, " " * indent)
  end

  def min3(a, b, c) # :nodoc:
    if a < b && a < c
      a
    elsif b < c
      b
    else
      c
    end
  end

  # Returns a value representing the "cost" of transforming str1 into str2
  # Vendored version of DidYouMean::Levenshtein.distance from the ruby/did_you_mean gem @ 1.4.0
  # https://github.com/ruby/did_you_mean/blob/2ddf39b874808685965dbc47d344cf6c7651807c/lib/did_you_mean/levenshtein.rb#L7-L37
  def levenshtein_distance(str1, str2)
    str1_length = str1.length
    str2_length = str2.length
    return str2_length if str1_length.zero?
    return str1_length if str2_length.zero?

    distances = (0..str2_length).to_a
    current_distance = nil

    # to avoid duplicating an enumerable object, create it outside of the loop
    str2_codepoints = str2.codepoints

    str1.each_codepoint.with_index(1) do |char1, str1_index|
      str2_index = 0
      left_cell = str1_index
      while str2_index < str2_length
        cost = char1 == str2_codepoints[str2_index] ? 0 : 1
        current_distance = min3(
          distances[str2_index + 1] + 1, # insertion
          left_cell + 1,                 # deletion
          distances[str2_index] + cost   # substitution
        )
        distances[str2_index] = left_cell
        left_cell = current_distance

        str2_index += 1
      end
      distances[str2_length] = current_distance
    end

    current_distance
  end
end

# typed: true
# frozen_string_literal: true

class Date
  extend T::Sig

  # Renders a human-friendly date string.
  #
  # Examples:
  #   Date.new(2026, 4, 13).to_human # => "Apr 13" (when current year is 2026)
  #   Date.new(2025, 4, 13).to_human # => "Apr 13, 2025"
  sig { returns(String) }
  def to_human
    if year == Date.current.year
      strftime("%b %-d")
    else
      strftime("%b %-d, %Y")
    end
  end
end

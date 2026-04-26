# typed: true
# frozen_string_literal: true

# Renders a human-friendly time string.
#
# Examples:
#   Time.zone.local(2026, 4, 13, 14, 30).to_human # => "2:30pm Apr 13"
#   Time.zone.local(2025, 4, 13, 14, 30).to_human # => "2:30pm Apr 13, 2025"

class Time
  extend T::Sig

  sig { returns(String) }
  def to_human
    if year == Date.current.year
      strftime("%-l:%M%P %b %-d")
    else
      strftime("%-l:%M%P %b %-d, %Y")
    end
  end
end

class DateTime # rubocop:disable Style/OneClassPerFile
  extend T::Sig

  sig { returns(String) }
  def to_human
    if year == Date.current.year
      strftime("%-l:%M%P %b %-d")
    else
      strftime("%-l:%M%P %b %-d, %Y")
    end
  end
end

class ActiveSupport::TimeWithZone # rubocop:disable Style/OneClassPerFile
  extend T::Sig

  sig { returns(String) }
  def to_human
    if year == Date.current.year
      strftime("%-l:%M%P %b %-d")
    else
      strftime("%-l:%M%P %b %-d, %Y")
    end
  end
end

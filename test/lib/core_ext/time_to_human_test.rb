# typed: true
# frozen_string_literal: true

require "test_helper"

class TimeToHumanTest < ActiveSupport::TestCase
  test "Time renders without year when same as current year" do
    travel_to Time.zone.local(2026, 6, 1) do
      assert_equal "2:30pm Apr 13", Time.zone.local(2026, 4, 13, 14, 30).to_human
      assert_equal "12:05am Apr 13", Time.zone.local(2026, 4, 13, 0, 5).to_human
      assert_equal "12:00pm Apr 13", Time.zone.local(2026, 4, 13, 12, 0).to_human
    end
  end

  test "Time renders with year when different from current year" do
    travel_to Time.zone.local(2026, 6, 1) do
      assert_equal "2:30pm Apr 13, 2025", Time.zone.local(2025, 4, 13, 14, 30).to_human
    end
  end

  test "DateTime renders correctly" do
    travel_to Time.zone.local(2026, 6, 1) do
      assert_equal "2:30pm Apr 13", DateTime.new(2026, 4, 13, 14, 30).to_human
      assert_equal "2:30pm Apr 13, 2025", DateTime.new(2025, 4, 13, 14, 30).to_human
    end
  end

  test "TimeWithZone renders correctly" do
    travel_to Time.zone.local(2026, 6, 1) do
      twz = Time.zone.local(2026, 4, 13, 9, 15)

      assert_kind_of ActiveSupport::TimeWithZone, twz
      assert_equal "9:15am Apr 13", twz.to_human
    end
  end
end

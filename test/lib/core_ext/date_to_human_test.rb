# typed: true
# frozen_string_literal: true

require "test_helper"

class DateToHumanTest < ActiveSupport::TestCase
  test "renders without year when same as current year" do
    travel_to Time.zone.local(2026, 6, 1) do
      assert_equal "Apr 13", Date.new(2026, 4, 13).to_human
      assert_equal "Apr 3", Date.new(2026, 4, 3).to_human
    end
  end

  test "renders with year when different from current year" do
    travel_to Time.zone.local(2026, 6, 1) do
      assert_equal "Apr 13, 2025", Date.new(2025, 4, 13).to_human
      assert_equal "Jan 1, 2030", Date.new(2030, 1, 1).to_human
    end
  end
end

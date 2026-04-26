# typed: true
# frozen_string_literal: true

class Analytics::GroupBy < T::Enum
  enums do
    Month = new(:month)
    Week = new(:week)
    Day = new(:day)
    Hour = new(:hour)
    Minute = new(:minute)
  end
end

# typed: true
# frozen_string_literal: true

class Analytics::GroupBy < T::Enum
  enums do
    Year = new(:year)
    Quarter = new(:quarter)
    Month = new(:month)
    Week = new(:week)
    Day = new(:day)
    Hour = new(:hour)
    Minute = new(:minute)
  end

  def human_name
    const_name.humanize
  end
end

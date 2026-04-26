# typed: true
# frozen_string_literal: true

class Analytics::Period < T::Enum
  enums do
    Last3Days = new(:last_3_days)
    Last7Days = new(:last_7_days)
    Last30Days = new(:last_30_days)
    Last90Days = new(:last_90_days)
    LastYear = new(:last_year)
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def start_date
    case self
    when Last3Days then 3.days.ago
    when Last7Days then 7.days.ago
    when Last30Days then 30.days.ago
    when Last90Days then 90.days.ago
    when LastYear then 1.year.ago
    else T.absurd(self)
    end
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def end_date
    Time.current
  end

  sig { returns(T::Array[Analytics::GroupBy]) }
  def allowed_group_bys
    case self
    when Last3Days then [Analytics::GroupBy::Hour, Analytics::GroupBy::Minute, Analytics::GroupBy::Day]
    when Last7Days then [Analytics::GroupBy::Day, Analytics::GroupBy::Hour]
    when Last30Days then [Analytics::GroupBy::Day, Analytics::GroupBy::Week]
    when Last90Days then [Analytics::GroupBy::Day, Analytics::GroupBy::Week, Analytics::GroupBy::Month]
    when LastYear then [Analytics::GroupBy::Month, Analytics::GroupBy::Week, Analytics::GroupBy::Quarter]
    else T.absurd(self)
    end
  end

  sig { returns(Analytics::GroupBy) }
  def default_group_by
    T.must(allowed_group_bys.first)
  end

  sig { params(group_by: Analytics::GroupBy).returns(T::Boolean) }
  def allows?(group_by)
    allowed_group_bys.include?(group_by)
  end

  sig { returns(String) }
  def human_name
    case self
    when Last3Days then "Last 3 days"
    when Last7Days then "Last 7 days"
    when Last30Days then "Last 30 days"
    when Last90Days then "Last 90 days"
    when LastYear then "Last year"
    else T.absurd(self)
    end
  end
end

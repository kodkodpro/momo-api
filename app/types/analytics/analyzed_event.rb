# typed: true
# frozen_string_literal: true

class Analytics::AnalyzedEvent < T::Struct
  prop :event_name, Analytics::EventName
  prop :start_date, T.any(Time, ActiveSupport::TimeWithZone)
  prop :end_date, T.any(Time, ActiveSupport::TimeWithZone)
  prop :group_by, Analytics::GroupBy
  prop :total_count, Integer, default: 0
  prop :grouped_counts, T::Hash[Date, Integer], default: {}
end

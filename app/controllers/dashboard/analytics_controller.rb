# typed: true
# frozen_string_literal: true

class Dashboard::AnalyticsController < Dashboard::ApplicationController
  def analyze_event
    event_name = parse_event_name
    period = parse_period
    group_by = parse_group_by(period)

    service = Analytics::AnalyzeEvent.run!(
      event_name:,
      period:,
      group_by:,
    )

    render Views::Dashboard::Analytics::AnalyzeEvent.new(analyzed_event: service.analyzed_event)
  end

  private

  sig { returns(Analytics::EventName) }
  def parse_event_name
    Analytics::EventName.deserialize(params[:event_name].to_i)
  rescue KeyError
    T.must(Analytics::EventName.values.first)
  end

  sig { returns(Analytics::Period) }
  def parse_period
    Analytics::Period.deserialize(params[:period].to_s.to_sym)
  rescue KeyError
    Analytics::Period::Last30Days
  end

  sig { params(period: Analytics::Period).returns(Analytics::GroupBy) }
  def parse_group_by(period)
    group_by = Analytics::GroupBy.deserialize(params[:group_by].to_s)
    period.allows?(group_by) ? group_by : period.default_group_by
  rescue KeyError
    period.default_group_by
  end
end

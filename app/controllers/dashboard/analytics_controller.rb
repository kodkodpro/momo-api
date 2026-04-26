# typed: true
# frozen_string_literal: true

class Dashboard::AnalyticsController < Dashboard::ApplicationController
  def analyze_event
    event_name = Analytics::EventName.deserialize(params[:event_name].to_i)

    service = Analytics::AnalyzeEvent.run!(
      event_name:,
      start_date: 28.days.ago,
      end_date: Time.current,
      group_by: Analytics::GroupBy::Day,
    )

    render Views::Dashboard::Analytics::AnalyzeEvent.new(analyzed_event: service.analyzed_event)
  end
end

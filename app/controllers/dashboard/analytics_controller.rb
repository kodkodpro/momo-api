# typed: true
# frozen_string_literal: true

class Dashboard::AnalyticsController < Dashboard::ApplicationController
  def analyze_event
    event_name = Analytics::EventName.deserialize(params[:event_name].to_i)

    service = Analytics::AnalyzeEvent.run!(
      event_name:,
      start_time: 7.days.ago,
      end_time: Time.current,
    )

    render Views::Dashboard::Analytics::AnalyzeEvent.new(data: service.data)
  end
end

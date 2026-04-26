# typed: true
# frozen_string_literal: true

class Analytics::AnalyzeEvent < ApplicationService
  # Arguments
  arg :event_name, type: Analytics::EventName
  arg :start_date, type: T.any(Time, ActiveSupport::TimeWithZone)
  arg :end_date, type: T.any(Time, ActiveSupport::TimeWithZone)
  arg :group_by, type: Analytics::GroupBy

  # Steps
  step :create_data_struct
  step :load_events
  step :calculate_total_count
  step :calculate_grouped_counts

  # Outputs
  output :analyzed_event, type: Analytics::AnalyzedEvent

  private

  sig { returns(AnalyticsEvent::RelationType) }
  attr_accessor :events

  def create_data_struct
    self.analyzed_event = Analytics::AnalyzedEvent.new(
      event_name:,
      start_date:,
      end_date:,
      group_by:,
    )
  end

  def load_events
    self.events = AnalyticsEvent.where(
      name: event_name.serialize,
      occurred_at: start_date..end_date,
    )
  end

  def calculate_total_count
    analyzed_event.total_count = events.count
  end

  def calculate_grouped_counts
    analyzed_event.grouped_counts = events
      .group_by_period(group_by.serialize, :occurred_at)
      .count
  end
end

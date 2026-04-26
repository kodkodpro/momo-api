# typed: true
# frozen_string_literal: true

class Analytics::AnalyzeEvent < ApplicationService
  # Arguments
  arg :event_name, type: Analytics::EventName
  arg :period, type: Analytics::Period
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
      period:,
      start_date: period.start_date,
      end_date: period.end_date,
      group_by:,
    )
  end

  def load_events
    self.events = AnalyticsEvent.where(
      name: event_name.serialize,
      occurred_at: analyzed_event.start_date..analyzed_event.end_date,
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

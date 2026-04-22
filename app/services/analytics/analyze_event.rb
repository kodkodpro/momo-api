# typed: true
# frozen_string_literal: true

class Analytics::AnalyzeEvent < ApplicationService
  # Structs
  class Data < T::Struct
    prop :event_name, Analytics::EventName
    prop :total_count, Integer, default: 0
  end

  # Arguments
  arg :event_name, type: Analytics::EventName
  arg :start_time, type: T.any(Time, ActiveSupport::TimeWithZone)
  arg :end_time, type: T.any(Time, ActiveSupport::TimeWithZone)

  # Steps
  step :create_data_struct
  step :load_events
  step :calculate_total_count

  # Outputs
  output :data, type: Data

  private

  sig { returns(AnalyticsEvent::RelationType) }
  attr_accessor :events

  def create_data_struct
    self.data = Data.new(event_name:)
  end

  def load_events
    self.events = AnalyticsEvent.where(name: event_name, occurred_at: start_time..end_time)
  end

  def calculate_total_count
    data.total_count = events.count
  end
end

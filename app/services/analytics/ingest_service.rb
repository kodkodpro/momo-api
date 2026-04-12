# typed: true
# frozen_string_literal: true

class Analytics::IngestService < ApplicationService
  # Arguments
  arg :user, type: User
  arg :events, type: Array

  private

  def run
    created_at = Time.current

    rows = []
    event_errors = []

    events.each_with_index do |event_hash, index|
      name = event_hash["name"]
      properties = event_hash["properties"] || {}

      enum_value = begin
        Analytics::EventName.deserialize(name)
      rescue KeyError
        event_errors << { index:, name:, error: "unknown event name" }
        next
      end

      begin
        enum_value.properties_schema.new(**properties.symbolize_keys)
      rescue ArgumentError, TypeError => e
        event_errors << { index:, name:, error: "invalid properties: #{e.message}" }
        next
      end

      occurred_at = begin
        Time.zone.parse(event_hash["occurred_at"].to_s)
      rescue ArgumentError, TypeError
        event_errors << { index:, name:, error: "invalid or missing occurred_at" }
        next
      end

      rows << {
        user_id: user.id,
        name:,
        properties:,
        occurred_at:,
        created_at:,
      }
    end

    AnalyticsEvent.insert_all(rows, returning: false) if rows.any? # rubocop:disable Rails/SkipsModelValidations
  end
end

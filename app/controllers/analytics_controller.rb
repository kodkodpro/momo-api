# typed: true
# frozen_string_literal: true

class AnalyticsController < ApplicationController
  def create
    Analytics::IngestService.run!(user: T.must(current_user), events: event_params)

    render json: { status: :created }, status: :created
  end

  private

  def event_params
    return [] unless params[:events].is_a?(Array)
    
    params[:events].map do |event|
      event
        .to_unsafe_h
        .deep_transform_keys(&:underscore)
    end
  end
end

# typed: strict
# frozen_string_literal: true

class Dashboard::ApplicationController < ActionController::Base
  # Includes
  include Memery

  # Configuration
  layout -> { Components::Layout }

  # Callbacks
  before_action :authenticate_dashboard

  private

  sig { void }
  def authenticate_dashboard
    authenticate_or_request_with_http_basic("Dashboard") do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, Env.dashboard_username) &
        ActiveSupport::SecurityUtils.secure_compare(password, Env.dashboard_password)
    end
  end
end

# typed: strict
# frozen_string_literal: true

class Dashboard::ApplicationController < ActionController::Base
  # Includes
  include Memery

  # Configuration
  layout -> { Components::Layout }
end

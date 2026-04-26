# typed: strict
# frozen_string_literal: true

class ApplicationController < ActionController::API
  # Includes
  include Memery

  # Callbacks
  before_action :current_user
  before_action :set_sentry_user

  # Error handling
  rescue_from Fren::AuthError, with: :handle_auth_error

  private

  sig { returns(User) }
  memoize def current_user
    user_id = request.headers["X-User-Id"]&.strip
    raise Fren::AuthError, "X-User-Id header is required" if user_id.blank?

    uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    raise Fren::AuthError, "X-User-Id header must be a valid UUID" unless user_id.match?(uuid_regex)

    User.find_or_create_by!(id: user_id)
  end

  sig { void }
  def set_sentry_user
    Sentry.set_user(id: current_user.id)
  end

  sig { params(error: Fren::AuthError).void }
  def handle_auth_error(error)
    render json: { status: :error, error: error.message }, status: :unauthorized
  end
end

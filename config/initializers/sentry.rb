# typed: true
# frozen_string_literal: true

if Rails.env.production?
  raise "SENTRY_DSN is required in production" if Env.sentry_dsn.blank?
  raise "SENTRY_ENVIRONMENT is required in production" if Env.sentry_environment.blank?
end

Sentry.init do |config|
  config.dsn = Env.sentry_dsn
  config.environment = Env.sentry_environment

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0
end

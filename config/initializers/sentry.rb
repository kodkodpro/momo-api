# typed: true
# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Env.sentry_dsn
  config.environment = Env.sentry_environment

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  config.traces_sample_rate = 1.0
end

# typed: strict
# frozen_string_literal: true

# Test uses :null_store for Rails.cache, and development can run without Redis,
# so give Rack::Attack its own MemoryStore in those envs. Production piggybacks
# on the Redis-backed Rails.cache so counters are shared across Puma workers.
if Rails.env.test?
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
else
  Rack::Attack.cache.store = Rails.cache
end

USER_DISCRIMINATOR = T.let(
  -> (req) { req.get_header("HTTP_X_USER_ID").presence || req.ip },
  T.proc.params(req: Rack::Request).returns(T.nilable(String)),
)

Rack::Attack.safelist("allow /up") { |req| req.path == "/up" }

Rack::Attack.safelist("allow sentry triggers in dev") do |req|
  Rails.env.local? && req.path.start_with?("/health/trigger-sentry")
end

# Open AI
Rack::Attack.throttle("proxy/openai burst", limit: 20, period: 1.minute) do |req|
  USER_DISCRIMINATOR.call(req) if req.path.start_with?("/proxy/openai")
end

Rack::Attack.throttle("proxy/openai sustained", limit: 300, period: 1.hour) do |req|
  USER_DISCRIMINATOR.call(req) if req.path.start_with?("/proxy/openai")
end

# ElevenLabs
Rack::Attack.throttle("proxy/elevenlabs burst", limit: 10, period: 1.minute) do |req|
  USER_DISCRIMINATOR.call(req) if req.path.start_with?("/proxy/elevenlabs")
end

Rack::Attack.throttle("proxy/elevenlabs sustained", limit: 60, period: 1.hour) do |req|
  USER_DISCRIMINATOR.call(req) if req.path.start_with?("/proxy/elevenlabs")
end

# Feedbacks
Rack::Attack.throttle("feedbacks#create burst", limit: 5, period: 1.minute) do |req|
  USER_DISCRIMINATOR.call(req) if req.path == "/feedbacks" && req.post?
end

Rack::Attack.throttle("feedbacks#create sustained", limit: 30, period: 1.hour) do |req|
  USER_DISCRIMINATOR.call(req) if req.path == "/feedbacks" && req.post?
end

# Remote config
Rack::Attack.throttle("remote-config", limit: 30, period: 1.minute) do |req|
  USER_DISCRIMINATOR.call(req) if req.path == "/remote-config"
end

# Fallback
Rack::Attack.throttle("req/ip fallback", limit: 300, period: 1.minute, &:ip)

# Handle throttled responses with a custom message and status code
Rack::Attack.throttled_responder = -> (req) {
  match_data = req.env["rack.attack.match_data"] || {}
  period = match_data[:period].to_i
  now = match_data[:epoch_time].to_i
  retry_after = period.zero? ? 0 : period - (now % period)

  [
    429,
    {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s,
    },
    [{ error: "rate_limited", retry_after: }.to_json],
  ]
}

# Notify Sentry whenever a throttle limit is exceeded so we can see which
# users/rules are hitting limits. Fires only when the throttle's limit is
# actually exceeded (see Rack::Attack::Check#call).
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  match_data = req.env["rack.attack.match_data"] || {}
  matched = req.env["rack.attack.matched"]
  discriminator = req.env["rack.attack.match_discriminator"]
  user_id = req.get_header("HTTP_X_USER_ID").presence
  fingerprint = ["rack_attack", matched, discriminator].compact

  Sentry.with_scope do |scope|
    scope.set_fingerprint(fingerprint)
    scope.set_user(id: user_id) if user_id

    scope.set_tags(
      rack_attack_rule: matched,
      rack_attack_period: match_data[:period],
    )

    scope.set_context("rack_attack", {
      rule: matched,
      discriminator:,
      path: req.path,
      method: req.request_method,
      count: match_data[:count],
      limit: match_data[:limit],
      period: match_data[:period],
    })

    Sentry.capture_message("Rack::Attack throttled: #{matched}", level: :warning)
  end
end

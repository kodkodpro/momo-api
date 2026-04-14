# typed: true
# frozen_string_literal: true

class ProxyController < ApplicationController
  def openai
    uri = build_target_uri
    upstream = execute_request(uri)

    notify_sentry(upstream) unless upstream.is_a?(Net::HTTPSuccess)

    render body: upstream.body,
           status: upstream.code.to_i,
           content_type: upstream["Content-Type"]
  end

  private

  def build_target_uri
    target = "#{Env.openai_api_url}/#{request.path_parameters[:path]}"
    target += "?#{request.query_string}" if request.query_string.present?
    URI.parse(target)
  end

  def execute_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    req = net_http_request_class.new(uri)
    req["Authorization"] = "Bearer #{Env.openai_api_key}"
    req["Content-Type"] = request.headers["Content-Type"] if request.headers["Content-Type"]
    req["Accept"] = request.headers["Accept"] if request.headers["Accept"]
    req.body = request.raw_post if request.post? || request.put? || request.patch?

    http.request(req)
  end

  def notify_sentry(upstream)
    Sentry.capture_message(
      "OpenAI Proxy Error",
      level: :error,
      extra: { status: upstream.code.to_i, body: upstream.body, path: request.path },
    )
  end

  def net_http_request_class
    case request.method
    when "GET" then Net::HTTP::Get
    when "POST" then Net::HTTP::Post
    when "PUT" then Net::HTTP::Put
    when "PATCH" then Net::HTTP::Patch
    when "DELETE" then Net::HTTP::Delete
    when "HEAD" then Net::HTTP::Head
    when "OPTIONS" then Net::HTTP::Options
    else
      raise ArgumentError, "Unsupported HTTP method: #{request.method}"
    end
  end
end

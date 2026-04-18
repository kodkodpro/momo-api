# typed: true
# frozen_string_literal: true

require "test_helper"

class ElevenlabsProxyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @elevenlabs_base = Env.elevenlabs_api_url
    @elevenlabs_key = Env.elevenlabs_api_key
  end

  test "forwards GET requests and returns upstream response" do
    stub_request(:get, "#{@elevenlabs_base}/v1/voices")
      .to_return(status: 200, body: '{"voices":[]}', headers: { "Content-Type" => "application/json" })

    get proxy_elevenlabs_url(path: "v1/voices"), headers: auth_headers

    assert_response :success
    assert_equal '{"voices":[]}', response.body
  end

  test "forwards POST requests with body" do
    request_body = '{"text":"hello","model_id":"eleven_multilingual_v2"}'

    stub_request(:post, "#{@elevenlabs_base}/v1/text-to-speech/voice_id")
      .with(body: request_body)
      .to_return(status: 200, body: "audio-bytes", headers: { "Content-Type" => "audio/mpeg" })

    post proxy_elevenlabs_url(path: "v1/text-to-speech/voice_id"),
         params: request_body,
         headers: auth_headers.merge("Content-Type" => "application/json")

    assert_response :success
    assert_equal "audio-bytes", response.body
  end

  test "injects xi-api-key header" do
    stub_request(:get, "#{@elevenlabs_base}/v1/voices")
      .with(headers: { "xi-api-key" => @elevenlabs_key })
      .to_return(status: 200, body: "{}")

    get proxy_elevenlabs_url(path: "v1/voices"), headers: auth_headers

    assert_response :success
  end

  test "forwards PUT requests" do
    stub_request(:put, "#{@elevenlabs_base}/v1/voices/voice_id/settings/edit")
      .to_return(status: 200, body: '{"updated":true}')

    put proxy_elevenlabs_url(path: "v1/voices/voice_id/settings/edit"),
        params: '{"stability":0.5}',
        headers: auth_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "forwards PATCH requests" do
    stub_request(:patch, "#{@elevenlabs_base}/v1/voices/voice_id")
      .to_return(status: 200, body: '{"patched":true}')

    patch proxy_elevenlabs_url(path: "v1/voices/voice_id"),
          params: '{"name":"test"}',
          headers: auth_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "forwards DELETE requests" do
    stub_request(:delete, "#{@elevenlabs_base}/v1/voices/voice_id")
      .to_return(status: 200, body: '{"deleted":true}')

    delete proxy_elevenlabs_url(path: "v1/voices/voice_id"), headers: auth_headers

    assert_response :success
  end

  test "preserves query parameters" do
    stub_request(:get, "#{@elevenlabs_base}/v1/history")
      .with(query: { "page_size" => "10" })
      .to_return(status: 200, body: '{"history":[]}')

    get proxy_elevenlabs_url(path: "v1/history"), params: { page_size: 10 }, headers: auth_headers

    assert_response :success
  end

  test "returns upstream 401 error as-is" do
    stub_request(:get, "#{@elevenlabs_base}/v1/voices")
      .to_return(status: 401, body: '{"error":"unauthorized"}')

    get proxy_elevenlabs_url(path: "v1/voices"), headers: auth_headers

    assert_response :unauthorized
  end

  test "forwards multipart/form-data POST requests" do
    stub_request(:post, "#{@elevenlabs_base}/v1/voices/add")
      .to_return(status: 200, body: '{"voice_id":"abc123"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"
    multipart_body = [
      "--#{boundary}",
      'Content-Disposition: form-data; name="name"',
      "",
      "My Voice",
      "--#{boundary}",
      'Content-Disposition: form-data; name="description"',
      "",
      "sample",
      "--#{boundary}--",
    ].join("\r\n")

    post proxy_elevenlabs_url(path: "v1/voices/add"),
         params: multipart_body,
         headers: auth_headers.merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")

    assert_response :success
    assert_equal '{"voice_id":"abc123"}', response.body
  end

  test "returns upstream 500 error as-is" do
    stub_request(:get, "#{@elevenlabs_base}/v1/voices")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    get proxy_elevenlabs_url(path: "v1/voices"), headers: auth_headers

    assert_response :internal_server_error
  end

  test "notifies Sentry on non-successful upstream response" do
    spy = Spy.on(Sentry, :capture_message)

    stub_request(:get, "#{@elevenlabs_base}/v1/voices")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    get proxy_elevenlabs_url(path: "v1/voices"), headers: auth_headers

    assert_spy_called spy
    assert_equal "ElevenLabs Proxy Error", spy.calls.first.args.first
  end

  test "does not notify Sentry on successful upstream response" do
    spy = Spy.on(Sentry, :capture_message)

    stub_request(:get, "#{@elevenlabs_base}/v1/voices")
      .to_return(status: 200, body: '{"voices":[]}', headers: { "Content-Type" => "application/json" })

    get proxy_elevenlabs_url(path: "v1/voices"), headers: auth_headers

    assert_spy_not_called spy
  end
end

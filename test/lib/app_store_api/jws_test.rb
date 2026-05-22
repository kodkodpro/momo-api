# typed: true
# frozen_string_literal: true

require "test_helper"

class AppStoreAPI::JWSTest < ActiveSupport::TestCase
  test "decodes a well-formed JWS payload and deep-underscores keys" do
    jws = build_jws({ "productId" => "com.fren.pro.yearly", "expiresDate" => 1_750_000_000_000 })

    decoded = AppStoreAPI::JWS.decode_payload(jws)

    assert_equal({ "product_id" => "com.fren.pro.yearly", "expires_date" => 1_750_000_000_000 }, decoded)
  end

  test "handles payloads whose length is not a multiple of 4 (padding required)" do
    payload = { "x" => "y" } # short body forces padding when base64-encoded
    jws = build_jws(payload)

    assert_equal payload, AppStoreAPI::JWS.decode_payload(jws)
  end

  test "raises on malformed JWS missing the payload segment" do
    assert_raises(AppStoreAPI::Error) { AppStoreAPI::JWS.decode_payload("abc..def") }
  end

  private

  def build_jws(payload)
    header_b64 = Base64.urlsafe_encode64({ alg: "ES256" }.to_json, padding: false)
    payload_b64 = Base64.urlsafe_encode64(payload.to_json, padding: false)
    "#{header_b64}.#{payload_b64}.fake-signature"
  end
end

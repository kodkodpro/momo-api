# typed: true
# frozen_string_literal: true

require "test_helper"

class AppStoreAPI::JWTTest < ActiveSupport::TestCase
  test "encodes claims that App Store Server API requires" do
    jwt = AppStoreAPI::JWT.generate

    key = OpenSSL::PKey::EC.new(Env.app_store_p8_pem)
    claims, header = ::JWT.decode(jwt, key, true, algorithm: "ES256")

    assert_equal "ES256", header["alg"]
    assert_equal "JWT", header["typ"]
    assert_equal Env.app_store_key_id, header["kid"]

    assert_equal Env.app_store_issuer_id, claims["iss"]
    assert_equal AppStoreAPI::AUDIENCE, claims["aud"]
    assert_equal Env.app_store_bundle_id, claims["bid"]
    assert_kind_of Integer, claims["iat"]
    assert_kind_of Integer, claims["exp"]
    assert_operator claims["exp"], :>, claims["iat"]
  end

  test "raises on signature verification when a different key is used" do
    jwt = AppStoreAPI::JWT.generate
    other_key = OpenSSL::PKey::EC.generate("prime256v1")

    assert_raises(::JWT::VerificationError) do
      ::JWT.decode(jwt, other_key, true, algorithm: "ES256")
    end
  end
end

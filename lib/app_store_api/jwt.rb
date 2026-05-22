# typed: true
# frozen_string_literal: true

# Generates ES256-signed JWTs for App Store Server API calls using the
# top-level ::JWT gem to do the JOSE encoding and ASN.1 DER → raw r||s
# signature conversion.
class AppStoreAPI::JWT
  TTL_SECONDS = 1200 # 20 minutes; Apple caps at 1 hour.

  class << self
    sig { returns(String) }
    def generate
      now = Time.now.to_i
      key = OpenSSL::PKey::EC.new(Env.app_store_p8_pem)

      claims = {
        iss: Env.app_store_issuer_id,
        iat: now,
        exp: now + TTL_SECONDS,
        aud: AppStoreAPI::AUDIENCE,
        bid: Env.app_store_bundle_id,
      }

      ::JWT.encode(claims, key, "ES256", { kid: Env.app_store_key_id, typ: "JWT" })
    end
  end
end

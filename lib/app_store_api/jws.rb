# typed: true
# frozen_string_literal: true

# Decodes the payload section of a JSON Web Signature without verifying the
# signature. We trust the TLS-terminated connection to Apple — the JWS body
# was just delivered over HTTPS from api.storekit*.itunes.apple.com.
class AppStoreAPI::JWS
  class << self
    sig { params(jws: String).returns(T::Hash[String, T.untyped]) }
    def decode_payload(jws)
      _header, payload, _signature = jws.split(".")
      raise AppStoreAPI::Error, "malformed JWS" if payload.blank?

      JSON.parse(Base64.urlsafe_decode64(pad(payload))).deep_transform_keys { it.to_s.underscore }
    end

    sig { params(str: String).returns(String) }
    def pad(str)
      str + ("=" * ((4 - (str.length % 4)) % 4))
    end
  end
end

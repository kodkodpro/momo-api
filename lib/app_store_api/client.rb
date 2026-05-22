# typed: true
# frozen_string_literal: true

class AppStoreAPI::Client
  class << self
    sig { params(transaction_id: String).returns(AppStoreAPI::StatusResponse) }
    def get_subscription_statuses(transaction_id)
      uri = URI.parse("#{AppStoreAPI.base_url}/inApps/v1/subscriptions/#{transaction_id}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{AppStoreAPI::JWT.generate}"
      req["Accept"] = "application/json"

      res = http.request(req)

      unless res.is_a?(Net::HTTPSuccess)
        raise AppStoreAPI::Error, "App Store Server API returned HTTP #{res.code}: #{res.body}"
      end

      body = T.must(res.body)
      hash = JSON.parse(body).deep_transform_keys { it.to_s.underscore }

      AppStoreAPI::StatusResponse.deserialize_from!(:hash, hash)
    end
  end
end

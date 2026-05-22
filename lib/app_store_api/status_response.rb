# typed: true
# frozen_string_literal: true

class AppStoreAPI::StatusResponse < T::Struct
  const :environment, String
  const :bundle_id, String
  const :data, T::Array[AppStoreAPI::SubscriptionGroup]
end

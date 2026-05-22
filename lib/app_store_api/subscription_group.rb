# typed: true
# frozen_string_literal: true

class AppStoreAPI::SubscriptionGroup < T::Struct
  const :subscription_group_identifier, String
  const :last_transactions, T::Array[AppStoreAPI::LastTransaction]
end

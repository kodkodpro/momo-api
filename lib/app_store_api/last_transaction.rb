# typed: true
# frozen_string_literal: true

class AppStoreAPI::LastTransaction < T::Struct
  const :original_transaction_id, String
  const :status, Integer
  const :signed_transaction_info, String
  const :signed_renewal_info, T.nilable(String)
end

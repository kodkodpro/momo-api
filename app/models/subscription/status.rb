# typed: true
# frozen_string_literal: true

class Subscription::Status < T::Enum
  enums do
    Active         = new(1)
    Expired        = new(2)
    InBillingRetry = new(3)
    InGracePeriod  = new(4)
    Revoked        = new(5)
  end
end

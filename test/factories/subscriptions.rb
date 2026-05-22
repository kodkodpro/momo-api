# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user
    transaction_id { SecureRandom.hex(10) }
    status { Subscription::Status::Active.serialize }
    data { {} }
    refreshed_at { Time.current }

    trait :active do
      status { Subscription::Status::Active.serialize }
    end

    trait :expired do
      status { Subscription::Status::Expired.serialize }
    end

    trait :in_billing_retry do
      status { Subscription::Status::InBillingRetry.serialize }
    end

    trait :in_grace_period do
      status { Subscription::Status::InGracePeriod.serialize }
    end

    trait :revoked do
      status { Subscription::Status::Revoked.serialize }
    end

    trait :stale do
      refreshed_at { 2.hours.ago }
    end
  end
end

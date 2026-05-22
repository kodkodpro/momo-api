# typed: true
# frozen_string_literal: true

require "test_helper"

class Subscription::StatusTest < ActiveSupport::TestCase
  test "serialized values match Apple App Store Server API status codes" do
    assert_equal 1, Subscription::Status::Active.serialize
    assert_equal 2, Subscription::Status::Expired.serialize
    assert_equal 3, Subscription::Status::InBillingRetry.serialize
    assert_equal 4, Subscription::Status::InGracePeriod.serialize
    assert_equal 5, Subscription::Status::Revoked.serialize
  end

  test "from_serialized round-trips Apple's codes" do
    assert_equal Subscription::Status::Active, Subscription::Status.from_serialized(1)
    assert_equal Subscription::Status::Expired, Subscription::Status.from_serialized(2)
    assert_equal Subscription::Status::InBillingRetry, Subscription::Status.from_serialized(3)
    assert_equal Subscription::Status::InGracePeriod, Subscription::Status.from_serialized(4)
    assert_equal Subscription::Status::Revoked, Subscription::Status.from_serialized(5)
  end
end

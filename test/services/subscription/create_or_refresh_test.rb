# typed: true
# frozen_string_literal: true

require "test_helper"

class Subscription::CreateOrRefreshTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @transaction_id = "tx-#{SecureRandom.hex(4)}".freeze
  end

  # New subscriptions

  test "creates a subscription from Apple's response" do
    stub_apple(status: 1)

    result = Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)

    sub = result.subscription

    assert_predicate sub, :persisted?
    assert_equal @user.id, sub.user_id
    assert_equal @transaction_id, sub.transaction_id
    assert_equal Subscription::Status::Active, sub.status
    assert_in_delta Time.current, sub.refreshed_at, 5.seconds
  end

  test "stores decoded JWS payloads under data" do
    stub_apple(status: 1)

    result = Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)
    data = result.subscription.data

    assert_equal "Sandbox", data["environment"]
    assert_equal "com.example.fren", data["bundle_id"]
    assert_equal "com.fren.pro.yearly", data.dig("transaction_info", "product_id")
    assert_equal 1, data.dig("renewal_info", "auto_renew_status")
  end

  # Refresh / TTL

  test "skips the Apple call when an entitled subscription is fresh" do
    existing = create(:subscription, :active, user: @user, transaction_id: @transaction_id, refreshed_at: 30.minutes.ago)
    stub = stub_request(:get, /api.storekit-sandbox.itunes.apple.com/)

    result = Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)

    assert_not_requested stub
    assert_equal existing.id, result.subscription.id
    assert_in_delta 30.minutes.ago, result.subscription.refreshed_at, 5.seconds
  end

  test "refreshes when an entitled subscription is past its TTL" do
    create(:subscription, :active, :stale, user: @user, transaction_id: @transaction_id)
    stub_apple(status: 2) # Apple now reports Expired

    result = Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)

    assert_equal Subscription::Status::Expired, result.subscription.status
    assert_in_delta Time.current, result.subscription.refreshed_at, 5.seconds
  end

  test "uses a 5-minute TTL for inactive subscriptions" do
    create(:subscription, :expired, user: @user, transaction_id: @transaction_id, refreshed_at: 10.minutes.ago)
    stub_apple(status: 1) # Apple now reports Active (renewal happened)

    result = Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)

    assert_equal Subscription::Status::Active, result.subscription.status
  end

  test "does not refresh an inactive subscription within the 5-minute TTL" do
    create(:subscription, :expired, user: @user, transaction_id: @transaction_id, refreshed_at: 2.minutes.ago)
    stub = stub_request(:get, /api.storekit-sandbox.itunes.apple.com/)

    Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)

    assert_not_requested stub
  end

  # Error paths

  test "raises when Apple's response does not include the queried transaction" do
    stub_apple(status: 1, original_transaction_id: "other-tx")

    assert_raises(AppStoreAPI::Error) do
      Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)
    end
  end

  test "raises when Apple returns a non-2xx response" do
    stub_request(:get, /api.storekit-sandbox.itunes.apple.com/)
      .to_return(status: 500, body: "{}")

    assert_raises(AppStoreAPI::Error) do
      Subscription::CreateOrRefresh.run!(user_id: @user.id, transaction_id: @transaction_id)
    end
  end

  private

  def stub_apple(status:, original_transaction_id: nil)
    original_transaction_id ||= @transaction_id

    signed_transaction = signed_jws({ "productId" => "com.fren.pro.yearly", "expiresDate" => 1_750_000_000_000 })
    signed_renewal = signed_jws({ "autoRenewStatus" => 1 })

    body = {
      environment: "Sandbox",
      bundleId: "com.example.fren",
      data: [

        subscriptionGroupIdentifier: "group-1",
        lastTransactions: [

          originalTransactionId: original_transaction_id,
          status:,
          signedTransactionInfo: signed_transaction,
          signedRenewalInfo: signed_renewal,

        ],

      ],
    }.to_json

    stub_request(:get, "https://api.storekit-sandbox.itunes.apple.com/inApps/v1/subscriptions/#{@transaction_id}")
      .to_return(status: 200, body:, headers: { "Content-Type" => "application/json" })
  end

  def signed_jws(payload)
    header = Base64.urlsafe_encode64({ alg: "ES256" }.to_json, padding: false)
    body = Base64.urlsafe_encode64(payload.to_json, padding: false)
    "#{header}.#{body}.sig"
  end
end

# typed: true
# frozen_string_literal: true

require "test_helper"

class AppStoreAPI::ClientTest < ActiveSupport::TestCase
  test "hits the sandbox base URL when configured" do
    stub_request(:get, "#{AppStoreAPI::SANDBOX_BASE_URL}/inApps/v1/subscriptions/tx-1")
      .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

    AppStoreAPI::Client.get_subscription_statuses("tx-1")

    assert_requested :get, "#{AppStoreAPI::SANDBOX_BASE_URL}/inApps/v1/subscriptions/tx-1"
  end

  test "hits the production base URL when configured" do
    Spy.on(Env, :app_store_environment).and_return("production")

    stub_request(:get, "#{AppStoreAPI::PRODUCTION_BASE_URL}/inApps/v1/subscriptions/tx-1")
      .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

    AppStoreAPI::Client.get_subscription_statuses("tx-1")

    assert_requested :get, "#{AppStoreAPI::PRODUCTION_BASE_URL}/inApps/v1/subscriptions/tx-1"
  end

  test "sends a Bearer token in the Authorization header" do
    stub = stub_request(:get, "#{AppStoreAPI::SANDBOX_BASE_URL}/inApps/v1/subscriptions/tx-1")
      .with { |req| req.headers["Authorization"].to_s.start_with?("Bearer ") }
      .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

    AppStoreAPI::Client.get_subscription_statuses("tx-1")

    assert_requested(stub)
  end

  test "raises AppStoreAPI::Error on non-2xx responses" do
    stub_request(:get, "#{AppStoreAPI::SANDBOX_BASE_URL}/inApps/v1/subscriptions/tx-1")
      .to_return(status: 404, body: '{"errorCode":4040010,"errorMessage":"Transaction id not found."}')

    assert_raises(AppStoreAPI::Error) do
      AppStoreAPI::Client.get_subscription_statuses("tx-1")
    end
  end

  test "deserializes the response into a typed StatusResponse" do
    stub_request(:get, "#{AppStoreAPI::SANDBOX_BASE_URL}/inApps/v1/subscriptions/tx-1")
      .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })

    res = AppStoreAPI::Client.get_subscription_statuses("tx-1")
    last_transactions = T.must(T.must(res.data.first).last_transactions.first)

    assert_kind_of AppStoreAPI::StatusResponse, res
    assert_equal "Sandbox", res.environment
    assert_equal "com.example.fren", res.bundle_id
    assert_equal "tx-1", last_transactions.original_transaction_id
    assert_equal 1, last_transactions.status
  end

  private

  def response_body
    {
      environment: "Sandbox",
      bundleId: "com.example.fren",
      data: [
        subscriptionGroupIdentifier: "group-1",
        lastTransactions: [
          originalTransactionId: "tx-1",
          status: 1,
          signedTransactionInfo: "h.payload.s",
          signedRenewalInfo: "h.payload.s",
        ],
      ],
    }.to_json
  end
end

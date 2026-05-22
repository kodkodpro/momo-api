# typed: true
# frozen_string_literal: true

class Subscription::CreateOrRefresh < ApplicationService
  # Refresh TTLs: hit Apple at most once per hour for entitled subscriptions,
  # every five minutes for inactive ones so users see updates quickly after
  # renewing in the App Store.
  ENTITLED_TTL = 1.hour
  INACTIVE_TTL = 5.minutes

  # Arguments
  arg :user_id, type: String
  arg :transaction_id, type: String

  # Steps
  step :load_existing
  step :return_if_fresh
  step :fetch_from_apple
  step :find_matching_transaction
  step :upsert

  # Outputs
  output :subscription, type: Subscription

  private

  attr_accessor :existing, :response, :matched

  def load_existing
    self.existing = Subscription.find_by(transaction_id:)
  end

  def return_if_fresh
    return unless existing && fresh?(existing)

    self.subscription = existing
    stop!
  end

  def fetch_from_apple
    self.response = AppStoreAPI.get_subscription_statuses(transaction_id)
  end

  def find_matching_transaction
    self.matched = response.data
      .flat_map(&:last_transactions)
      .find { it.original_transaction_id == transaction_id }

    return if matched

    raise AppStoreAPI::Error, "transaction #{transaction_id} not found in Apple response"
  end

  def upsert
    sub = existing || Subscription.new(user_id:, transaction_id:)
    sub.status = matched.status
    sub.data = build_data
    sub.refreshed_at = Time.current
    sub.save!

    self.subscription = sub
  end

  def fresh?(sub)
    ttl = sub.entitled? ? ENTITLED_TTL : INACTIVE_TTL
    sub.refreshed_at > ttl.ago
  end

  def build_data
    transaction_info = AppStoreAPI::JWS.decode_payload(matched.signed_transaction_info)
    renewal_info = matched.signed_renewal_info && AppStoreAPI::JWS.decode_payload(matched.signed_renewal_info)

    {
      environment: response.environment,
      bundle_id: response.bundle_id,
      original_transaction_id: matched.original_transaction_id,
      transaction_info:,
      renewal_info:,
    }
  end
end

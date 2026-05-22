# typed: true
# frozen_string_literal: true

class Subscription < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  sorbet_enum :status, Subscription::Status

  # Validations
  validates :transaction_id, presence: true, uniqueness: true
  validates :status, presence: true
  validates :refreshed_at, presence: true

  # Apple keeps the user entitled during the grace period after a failed
  # renewal, so treat InGracePeriod as still usable.
  def entitled?
    active? || in_grace_period?
  end
end

# typed: true
# frozen_string_literal: true

class User < ApplicationRecord
  # Associations
  has_many :analytics_events, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
end

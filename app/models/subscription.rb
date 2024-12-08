class Subscription < ApplicationRecord
  belongs_to :user

  enum :status, %w[incomplete active trialing canceled incomplete_expired past_due unpaid].index_by(&:itself), default: "incomplete"

  delegate :email, to: :user
end

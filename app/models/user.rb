class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def subscribed? = Subscription.exists?(user: self, status: %w[active trialing])
end

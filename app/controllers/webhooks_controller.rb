class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %w[create]
  before_action :verify_webhook_signature, only: %w[create]
  before_action :render_empty_json, if: :webhook_exists?, only: %w[create]

  def create
    {
      "checkout.session.completed": checkout_session_completed
      # add other supported events here
    }[event_type]
  end

  private

  def checkout_session_completed
    subscription Stripe::Subscription.retrieve(event.data.object.subscription)

    User.find(event.data.object.client_reference_id).tap do |user|
      user.create_subscription(
        customer_id: event.data.object.customer,
        subscription_id: subscription.id,
        status: subscription.status,
        cancel_at: Time.at(subscription.cancel_at),
        current_period_end_at: Time.at(subscription.current_period_end)
      )
    end

    event.completed!
  end

  def verify_webhook_signature
    begin
      Stripe::Webhook.construct_event(
        request.body.read,
        request.env["HTTP_STRIPE_SIGNATURE"],
        ENV["STRIPE_SIGNING_SECRET"]
      )
    rescue Stripe::SignatureVerificationError
      return false
    end

    true
  end

  def render_empty_json
    render json: {}
  end

  def webhook_exists?
    Webhook.find_by(source_id: params[:id], source: "stripe")
  end

  def event_type = event.data[:type]

  def event = Webhook.create(webhook_params)

  def webhook_params
    {
      source: "stripe",
      source_id: params[:id],
      data: params.except(:source, :controller, :action)
    }
  end

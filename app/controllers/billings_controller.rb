class BillingsController < ApplicationController
  def create
    session = Stripe::Checkout::Session.create({
      success_url: root_url,
      cancel_url: root_url,
      client_reference_id: Current.user.slug,
      customer_email: Current.user.email,
      mode: "subscription",
      subscription_data: {
        trial_period_days: 30 # You can choose any number of trial days here
      },
      line_items: [{
        quantity: 1,
        price: "price_1234" # add your price id from Stripe here
      }]
    })

    redirect_to session.url, status: 303, allow_other_host: true
  end

  def edit
    session = Stripe::BillingPortal::Session.create({
      customer: Current.user.subscription.customer_id,
      return_url: root_url
    })

    redirect_to session.url, status: 303, allow_other_host: true
	end
end

class SubscribeStravaWebhook < ApplicationJob
  def perform
    client = Strava::Webhooks::Client.new(
      client_id: ENV.fetch('STRAVA_CLIENT_ID'),
      client_secret: ENV.fetch('STRAVA_CLIENT_SECRET')
    )
    callback_url = "#{WEBHOOK_HOSTNAME}/webhook"

    subscriptions = client.push_subscriptions
    subscription = subscriptions.first

    if subscription
      if subscriptions.callback_url == callback_url
        client.delete_push_subscription(subscription.id)
      else
        raise "Already have a subscription: #{subscription.callback_url}"
      end
    end

    client.create_push_subscription(
      callback_url: callback_url,
      verify_token: ENV.fetch("WEBHOOK_TOKEN")
    )
  end
end

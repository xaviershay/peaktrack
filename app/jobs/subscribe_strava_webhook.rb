class SubscribeStravaWebhook < ApplicationJob
  def perform
    callback_url = "#{HOSTNAME}/webhook"
    client = Strava::Webhooks::Client.new(
      client_id: ENV.fetch('STRAVA_CLIENT_ID'),
      client_secret: ENV.fetch('STRAVA_CLIENT_SECRET')
    )
    client.create_push_subscription(callback_url: callback_url, verify_token: 'token')
  end
end

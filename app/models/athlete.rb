class Athlete < ApplicationRecord
  serialize :oauth_token, AuthToken

  has_many :activities

  def current_token!
    token = oauth_token

    return token unless token.expired?

    client = Strava::OAuth::Client.new(
      client_id: ENV.fetch('STRAVA_CLIENT_ID'),
      client_secret: ENV.fetch('STRAVA_CLIENT_SECRET')
    )

    # TODO: Handle failure
    response = client.oauth_token(
      refresh_token: token.refresh_token,
      grant_type: 'refresh_token'
    )

    new_token = AuthToken.new(
      response.access_token,
      response.refresh_token,
      response.expires_at
    )

    self.update!(
      oauth_token: new_token
    )

    new_token
  end
end

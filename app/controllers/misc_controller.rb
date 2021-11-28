class MiscController < ApplicationController
  def home
  end

  def logout
    session[:current_athlete_id] = nil
    redirect_to '/'
  end

  def dashboard
    @athlete = Athlete.find(session[:current_athlete_id])
    @regions = Region.all
  rescue ActiveRecord::RecordNotFound
    redirect_url = oauth_client.authorize_url(
      redirect_uri: "#{HOSTNAME}/auth",
      response_type: 'code',
      scope: 'activity:read'
    )

    redirect_to redirect_url
  end

  def auth
    code = params.fetch('code')

    response = oauth_client.oauth_token(code: code)

    client = Strava::Api::Client.new(
      access_token: response.access_token
    )

    athlete = client.athlete
    new_token = AuthToken.new(
      response.access_token,
      response.refresh_token,
      response.expires_at
    )

    logged_in = begin
                  Athlete.find(athlete.id).tap {|x| x.update!(oauth_token: new_token) }
                rescue ActiveRecord::RecordNotFound
                  Athlete.create!(
                    id: a.id,
                    name: "%s %s" % [a.firstname, a.lastname],
                    profile_photo_url: a.profile,
                    oauth_token: new_token,
                    oldest_activity_at: Time.zone.now
                  ).tap {|x|
                    FetchOldActivities.perform_later(x.id)
                  }
                end

    session[:current_athlete_id] = logged_in.id

    redirect_to '/dashboard'
  end

  def oauth_client
    @oauth_client ||= Strava::OAuth::Client.new(
      client_id: ENV.fetch('STRAVA_CLIENT_ID'),
      client_secret: ENV.fetch('STRAVA_CLIENT_SECRET')
    )
  end
end

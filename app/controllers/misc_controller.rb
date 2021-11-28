class MiscController < ApplicationController
  def home
  end

  def logout
    session[:current_athlete_id] = nil
    redirect_to '/'
  end

  def webhook_register
    challenge = Strava::Webhooks::Models::Challenge.new(params)
    raise 'Bad Request' unless challenge.verify_token == 'token'

    render json: challenge.response
  end

  # Must respond in 2s
  def webhook_receive
    event = Strava::Webhooks::Models::Event.new(JSON.parse(request.body))

    case [event.object_type, event.aspect_type]
    when ['activity', 'create']
      athlete = Athlete.find(event.owner_id)
      # TODO: Should async this to not risk timing out
      client = Strava::Api::Client.new(
        access_token: token.access_token,
        #logger: Logger.new(STDOUT)
      )
      a = client.activity(event.object_id)
      return unless a.map && a.map.summary_polyline
      begin
        # TODO: DRY up with FetchOldActivities. Possible optimization to store
        # route here also.
        activity = athlete.activities.create!(
          id: a.id,
          name: a.name,
          started_at: a.start_date,
          route_summary: Route.from_polyline(a.map.summary_polyline)
        )
        IdentifyPeaksInActivity.perform_later(athlete.id, activity.id)
      rescue ActiveRecord::RecordNotUnique
      end
    when ['activity', 'update']
      begin
        if title = event.updates['title']
          activity = Activity.find(event.object_id)
          activity.update!(title: title)
        end
      rescue ActiveRecord::RecordNotUnique
      end
    when ['activity', 'delete']
      Activity.find(event.object_id).destroy
    end
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

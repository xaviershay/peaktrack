class FetchOldActivities < ApplicationJob
  queue_as :default

  def perform(athlete_id)
    athlete = Athlete.find(athlete_id)

    token = athlete.current_token!

    client = Strava::Api::Client.new(
      access_token: token.access_token,
      #logger: Logger.new(STDOUT)
    )

    as = client.athlete_activities(
      before: athlete.oldest_activity_at,
      per_page: 200
    )

    return if as.empty?

    as.each do |a|
      next unless a.map && a.map.summary_polyline

      begin
        activity = athlete.activities.create!(
          id: a.id,
          name: a.name,
          started_at: a.start_date,
          route_summary: Route.from_polyline(a.map.summary_polyline)
        )
        IdentifyPeaksInActivity.perform_later(athlete.id, activity.id)
      rescue ActiveRecord::RecordNotUnique
      end
    end

    athlete.update!(
      oldest_activity_at: as.map(&:start_date).sort.first
    )

    # TODO: uncomment and rate limit
    FetchOldActivities.perform_later(athlete.id)
  end
end

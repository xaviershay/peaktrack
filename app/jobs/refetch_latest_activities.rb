# TODO: DRY up with FetchOldActivities
class RefetchLatestActivities < ApplicationJob
  queue_as :default

  def perform(athlete_id)
    athlete = Athlete.find(athlete_id)

    token = athlete.current_token!

    client = Strava::Api::Client.new(
      access_token: token.access_token,
      #logger: Logger.new(STDOUT)
    )

    as = client.athlete_activities(
      before: Time.zone.now,
      per_page: 200
    )

    as.each do |a|
      next unless a.map && a.map.summary_polyline

      begin
        # TODO: DRY up with webhook_receive
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
  end
end

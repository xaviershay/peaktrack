class IdentifyPeaksInActivity < ApplicationJob
  SUMMIT_PROXIMITY_THRESHOLD = 30

  def perform(athlete_id, activity_id)
    athlete = Athlete.find(athlete_id)
    activity = athlete.activities.find(activity_id)
    candidates =
      Peak.in_bounds(self.class.add_buffer_to_bounds(activity.route_summary.bounds))
    return if candidates.empty?

    if activity.route.nil?
      token = athlete.current_token!

      client = Strava::Api::Client.new(
        access_token: token.access_token,
        # logger: Logger.new(STDOUT)
      )

      a = client.activity(activity.id)
      activity.update!(
        route: Route.from_polyline(a.map.polyline)
      )
    end

    points = activity.route.points
    candidates.each do |peak|
      if self.class.min_distance(peak, points) < SUMMIT_PROXIMITY_THRESHOLD
        ActivityPeak.find_or_create_by!(
          activity_id: activity.id,
          peak_id: peak.id
        )
      end
    end
  end

  def self.min_distance(peak, points)
    raise if points.empty?

    loc1 = [peak.lat, peak.lon]
    min_dist = 99999999999
    points.each do |loc2|
      d = distance(loc1, loc2)
      min_dist = d if d < min_dist
    end
    min_dist
  end

  # The bounds on an actual route can be larger than that of the route summary,
  # but we use the summary to determine if we should even load the real route.
  # As we're only using the bounds check as an optimization, widen the bounds
  # to possibly capture peaks near the border.
  #
  # 1 degree of latitude is ~110K.
  # 1 degree of longitute is also ~110K but shrinks to 0 at the poles.
  #
  # We'll expand 0.01 degree on each, this will be over-eager near the poles but
  # that's fine.
  def self.add_buffer_to_bounds(bounds)
    [
      [bounds[0][0] - 0.01, bounds[0][1] - 0.01],
      [bounds[1][0] + 0.01, bounds[1][1] + 0.01]
    ]
  end

  # From StackOverflow
  def self.distance(loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c # Delta in meters
  end
end

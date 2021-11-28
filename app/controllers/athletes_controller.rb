class AthletesController < ApplicationController
  def show
    @athlete = Athlete.find(params.fetch(:athlete_id))
    @region = Region.find(params.fetch(:region_id))
    @regions = Region.all
    @summary = AthleteRegionSummary.new(@athlete, @region).top(500)
  end

  def debug_activity
    activity = Activity.find(params.fetch(:id))
    render plain: JSON.pretty_generate({
      activity_id: activity.id,
      peaks: Peak.in_bounds(activity.route_summary.bounds).map {|p| {
        id: p.id,
        name: p.name,
        distance: IdentifyPeaksInActivity.min_distance(p, activity.route_summary.points)
      }}
    })
  end
end

class AthletesController < ApplicationController
  def show
    @athlete = Athlete.find(params.fetch(:athlete_id))
    @region = Region.find(params.fetch(:region_id))
    @regions = Region.all
    @summary = AthleteRegionSummary.new(@athlete, @region).top(500)
  end
end

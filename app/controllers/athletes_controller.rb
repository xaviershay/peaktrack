class AthletesController < ApplicationController
  def show
    @athlete = Athlete.find(params.fetch(:athlete_id))
    @region = Region.find(params.fetch(:region_id))
    @summary = AthleteRegionSummary.new(@athlete, @region).top(50)
  end
end

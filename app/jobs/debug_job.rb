class DebugJob < ApplicationJob
  def perform
    raise Strava::Errors::Fault.new(nil)
  end
end

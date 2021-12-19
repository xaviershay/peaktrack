class ApplicationJob < ActiveJob::Base
  retry_on Strava::Errors::Fault, attempts: :unlimited, wait: 15.minutes
end

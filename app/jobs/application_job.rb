class ApplicationJob < ActiveJob::Base
  retry_on Strava::Errors::Fault, wait: 15.minutes, attempts: :unlimited
end

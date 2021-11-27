class Activity < ApplicationRecord
  belongs_to :athlete

  serialize :route_summary, Route
end

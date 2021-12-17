class Activity < ApplicationRecord
  belongs_to :athlete
  has_many :activity_peaks, dependent: :destroy
  has_many :peaks, through: :activity_peaks

  serialize :route, Route
  serialize :route_summary, Route
end

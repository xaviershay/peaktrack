class Region < ApplicationRecord
  has_many :region_peaks
  has_many :peaks, through: :region_peaks
end

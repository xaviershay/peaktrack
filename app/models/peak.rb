class Peak < ApplicationRecord
  has_many :region_peaks
  has_many :regions, through: :region_peaks
end

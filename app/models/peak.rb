class Peak < ApplicationRecord
  has_many :region_peaks
  has_many :regions, through: :region_peaks

  def self.in_bounds(bounds)
    where(['lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?',
           bounds[0][0],
           bounds[1][0],
           bounds[0][1],
           bounds[1][1]
         ])
  end
end

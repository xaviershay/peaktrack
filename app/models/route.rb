require 'pry'
class Route
  attr_reader :points, :bounds

  def initialize(p, b)
    @points = p
    @bounds = b
  end

  def inspect
    "<Route bounds=%s (%i)>" % [
      bounds.inspect,
      (points.size rescue "0")
    ]
  end

  def self.extract_bounds(points)
    min = [86, 180]
    max = [-86, -180]

    points.each do |lat, lon|
      min = [ [lat, min[0]].min, [lon, min[1]].min]
      max = [ [lat, max[0]].max, [lon, max[1]].max]
    end

    [min, max]
  end

  def self.from_polyline(polyline)
    points = Polylines::Decoder.decode_polyline(polyline)
    bounds = extract_bounds(points)

    raise "fail: #{polyline}" unless points

    new(
      points,
      bounds
    )
  end

  def self.from_hash(hash)
    hash ||= {}

    new(
      Polylines::Decoder.decode_polyline(hash['polyline']),
      hash['bounds']
    )
  end

  def self.null
    nil
  end

  def self.load(string)
    return null unless string

    from_hash(JSON.parse(string))
  end

  def self.dump(obj)
    {
      polyline: obj.points && Polylines::Encoder.encode_points(obj.points),
      bounds: obj.bounds
    }.to_json
  end
end

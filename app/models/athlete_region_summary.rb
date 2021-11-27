class AthleteRegionSummary
  def initialize(athlete, region)
    @athlete = athlete
    @region = region
  end

  def top(n)
    sql = <<-SQL
SELECT p.name, p.elevation,
  FIRST_VALUE(a.started_at) OVER (PARTITION BY p.id ORDER BY a.started_at DESC) as started_at,
  FIRST_VALUE(a.id) OVER (PARTITION BY p.id ORDER BY a.started_at DESC) as activity_id,
  COUNT(a.id) OVER (PARTITION BY p.id ORDER BY a.started_at DESC) as summit_count
FROM
    region_peaks rp
  INNER JOIN
    peaks p ON rp.peak_id = p.id
  LEFT JOIN
    activity_peaks ap ON ap.peak_id = p.id
  LEFT JOIN
    activities a ON ap.activity_id = a.id
WHERE
  rp.region_id = $2
  AND (a.athlete_id = $1 OR a.athlete_id IS NULL)
ORDER BY
  p.elevation DESC
LIMIT $3
    SQL
    ApplicationRecord.connection.exec_query(
      sql,
      'SQL',
      [
        [nil, @athlete.id],
        [nil, @region.id],
        [nil, n]
      ],
      prepare: true
    ).map {|x| Record.new(
      x.fetch('name'),
      x.fetch('elevation'),
      x.fetch('activity_id'),
      x.fetch('started_at'),
      x.fetch('summit_count')
    ) }
  end

  class Record < Struct.new(:name, :elevation, :activity_id, :started_at, :summit_count)
  end
end

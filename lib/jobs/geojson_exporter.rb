class GeoJSONExporter

  attr_accessor :run, :count, :total, :geohash

  def initialize(run_id: nil, layers: nil)
    @run = run_id ? Run.find(run_id) : Run.last
    @layers = layers || [:applicants, :positions, :placements]
    @geohash = { type: 'FeatureCollection' }
    @count = 0
    @total = @run.exportable_placements.count
  end

  def perform
    generate
    $stdout << geojson
  end

  def to_file
    filename = "./tmp/exports/#{@layers.join('-')}-#{Time.now.to_i}.geojson"
    File.open(filename, 'wb') { |f| f << geojson }
  end

  def generate
    @geohash[:features] = @run.exportable_placements.flat_map(&method(:layers))
  end

  def geojson
    @geohash.to_json
  end

  def percent_message
    (@count / @total.to_f * 100).round(2)
  end

  def layers(placement)
    @layers.map { |layer| send("#{layer}_item", placement) }
  end

  def placements_item(placement)
    best_fit = placement.pool.pooled_positions.find_by(position_id: placement.position_id)
    masked = MaskedCoordinates.new(placement.applicant.location.coordinates.map{|c| c.round(6)})
    {
      type: "Feature",
      geometry: {
        type: "LineString",
        coordinates: [
          masked.coordinates,
          placement.position.location.coordinates.map{|c| c.round(6)}
        ]
      },
      properties: {
        travel_mode: placement.applicant.mode,
        total_score:    best_fit.score['total'],
        travel_score:   best_fit.score['components']['travel'],
        interest_score: best_fit.score['components']['interest']
      }
    }
  end

  def applicants_item(placement)
    applicant = placement.applicant
    masked = MaskedCoordinates.new(applicant.location.coordinates.map{|c| c.round(6)})
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: masked.coordinates
      },
      properties: {
        type:          :applicant,
        interests:      applicant.interests.join(', '),
        mode:           applicant.mode,
        prefers_nearby: applicant.prefers_nearby?,
        placed: placement.position_id.present?,
        base_pool:  placement.pool.position_count,
        total_pool: placement.pool.pooled_positions.count
      }
    }
  end

  def positions_item(placement)
    position = placement.position
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: position.location.coordinates.map{|c| c.round(6)}
      },
      properties: {
        type:     :position,
        category:  position.category,
        available: position.available?(@run)
      }
    }
  end

end

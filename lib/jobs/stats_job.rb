class StatsJob

  def initialize(id)
    @run = Run.find(id)
  end

  def perform!
    @stats = OpenStruct.new(
      matched_nearby: 0, matched_with_interest: 0,
      placement_rate: 0, average_travel_time: 0,
      geojson: {type: 'FeatureCollection', features: []}
    )

    @run.placements.includes(:applicant, :position).find_each do |placement|
      calculate_stats_for_placement(placement)
      build_geojson_for_placement(placement)
    end
    calculate_stats_for_run
    build_geojson_for_run
    @run.update_attribute(:statistics, @stats.to_h.to_json)
  end

  private

  def calculate_stats_for_placement(placement)
    applicant = placement.applicant
    position  = placement.position

    matched_nearby?(applicant, position)
    matched_with_interest?(applicant, position)
  end

  def calculate_stats_for_run
    @stats.placement_rate = placement_rate
    @stats.average_travel_time = average_travel_time
  end

  def build_geojson_for_placement(placement)
    @stats.geojson[:features] << placement_line(placement)
    @stats.geojson[:features] << applicant_point(placement.applicant, true)
    @stats.geojson[:features] << position_point(placement.position, true)
  end

  def build_geojson_for_run
    @run.unplaced.each do |id|
      @stats.geojson[:features] << applicant_point(Applicant.find(id), false)
    end
  end

  def average_travel_time
    @run.placements.extend(DescriptiveStatistics).mean(&:travel_time)
  end

  def placement_rate
    @run.unplaced.count.to_f / @run.placements.count.to_f
  end

  def matched_nearby?(a, p)
    if a.prefers_nearby && p.within?(10.minutes, of: a)
      @stats.matched_nearby += 1
    end
  end

  def matched_with_interest?(a, p)
    if a.prefers_nearby && p.within?(10.minutes, of: a)
      @stats.matched_nearby += 1
    end
  end

  def placement_line(placement)
    applicant = placement.applicant
    position = placement.position

    travel = TravelScore.new(applicant: applicant, position: position).score
    interest = InterestScore.new(applicant: applicant, position: position).score
    total = travel + interest
    { type: "Feature",
      geometry: {
        type: "LineString",
        coordinates: [
          applicant.location.coordinates,
          position.location.coordinates
        ]
      },
      properties: {
        score: { total: total, travel: travel, interest: interest },
        mode: applicant.mode
      }
    }
  end

  def applicant_point(applicant, placed)
    {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: applicant.location.coordinates
      },
      properties: {
        type: :applicant,
        interests: applicant.interests.join(', '),
        mode: applicant.mode,
        prefers_nearby: applicant.prefers_nearby?,
        placed: placed
      }
    }
  end

  def position_point(position, placed)
    {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: position.location.coordinates
      },
      properties: {
        type: :position,
        category: position.category,
        placed: placed
      }
    }
  end

end

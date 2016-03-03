class StatsJob

  def initialize(id)
    @run = Run.find(id)
  end

  # Statistics on each run => store in new field :statistics or something

  
  # How many people who cared about matching interest got a job with a matching interest?
  # How many people who cared about proximity got a job within a 15-minute commute?
  # Histogram of travel times, in 5-minute buckets
  # Average / median / total? travel times
  # GeoJSON of placements, connected by line; points for unplaced applicants

  def perform!
    geojson = {type: 'FeatureCollection', features: []}
    @counters = OpenStruct.new(
      matched_nearby: 0,
      matched_with_interest: 0,
      placement_rate: 0,
      average_travel_time: 0,
      geojson: geojson
    )
    # Also want to keep track of travel times.
    @run.placements.includes(:applicant, :position).find_each do |placement|
      applicant = placement.applicant
      position  = placement.position

      geojson[:features] << placement_line(placement)
      geojson[:features] << applicant_point(applicant, true)
      geojson[:features] << position_point(position, true)
      matched_nearby?(applicant, position)
      matched_with_interest?(applicant, position)
    end
    @run.unplaced.each do |id|
      geojson[:features] << applicant_point(Applicant.find(id), false)
    end


    # filename = "./tmp/exports/run-#{@run.id}-#{Time.now.to_i}.geojson"
    # File.open(filename, 'w') { |f| f.write(geojson.to_json) }

    placement_rate
    average_travel_time
    @run.statistics = @counters.to_json
    @run.save!

  end

  private

  def matched_nearby?(a, p)
    if a.prefers_nearby && p.within?(10.minutes, of: a)
      @counters.matched_nearby += 1
    end
  end

  def matched_with_interest?(a, p)
    if a.prefers_nearby && p.within?(10.minutes, of: a)
      @counters.matched_nearby += 1
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

  def average_travel_time
    @counters.average_travel_time = @run.placements.extend(DescriptiveStatistics).mean(&:travel_time)
  end

  def placement_rate
    placements = @run.placements.count.to_f
    unplaced = @run.unplaced.count.to_f
    @counters.placement_rate = (placements - unplaced) / placements
  end

end

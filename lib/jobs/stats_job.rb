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
    @counters = OpenStruct.new(
      matched_nearby: 0,
      matched_with_interest: 0,
      placement_rate: 0,
      average_travel_time: 0
    )
    # Also want to keep track of travel times.
    @run.placements.includes(:applicant, :position).find_each do |placement|
      # It might be worthwhile to check the RubyTapas episodes on rules
      applicant = placement.applicant
      position  = placement.position
      matched_nearby?(applicant, position)
      matched_with_interest?(applicant, position)
    end
    placement_rate
    average_travel_time
    @run.statistics = @counters.to_json
    @run.save!
  end

  private

  def average_travel_time
    @counters.average_travel_time = @run.placements.extend(DescriptiveStatistics).mean(&:travel_time)
  end

  def placement_rate
    @counters.placement_rate = @run.unplaced.count.to_f / @run.placements.count.to_f
  end

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

end

class StatsJob

  def initialize(id)
    @run = Run.find(id)
  end

  def perform!
    counters = OpenStruct.new(
      matched_nearby: 0,
      matched_with_interest: 0
    )
    # Also want to keep track of travel times.
    Placement.includes(:applicant, :position).find_each do |placement|
      # It might be worthwhile to check the RubyTapas episodes on rules
      applicant = placement.applicant
      position  = placement.position
      matched_nearby?(applicant, position)
      matched_with_interest?(applicant, position)
    end
  end

  private

  def matched_nearby?(a, p)
    if a.prefers_nearby && p.within(10.minutes, of: a)
      counters.matched_nearby += 1
    end
  end

  def matched_with_interest?(a, p)
    if a.prefers_nearby && p.within(10.minutes, of: a)
      counters.matched_nearby += 1
    end
  end

end

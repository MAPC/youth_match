class JobFinder

  def initialize(applicant: , run: )
    @applicant = applicant
    @run = run
  end

  def opportunities
    @opportunities ||= Position.available(@run).
      within(40.minutes, of: @applicant, via: @applicant.mode).
      map do |position|
        MatchScore.new(
          applicant: @applicant, position: position
        ).to_h
      end
  end
  alias_method :opps, :opportunities

  def best_job
    return nil if opps.count == 0
    best_job_id = opps.max_by { |opp| opp[:total] }[:position_id]
    Position.find(best_job_id)
  end

  def best_job_and_opportunities
    [best_job, opportunities]
  end

end

class MatchJob

  def perform!
    @run = Run.create!
    @run.running!
    Applicant.random.find_each do |applicant|
      best_job = find_best_job_for(applicant)
      @run.placements.create! applicant: applicant, position: best_job
    end
    @run.succeeded!
  rescue
    @run.failed!
  end

  def find_best_job_for(applicant)
    Position.available(@run)
      .within(40.minutes, of: applicant, via: applicant.mode)
      .max_by do |position|
        MatchScore.new(applicant: applicant, position: position).score
      end
  end

end

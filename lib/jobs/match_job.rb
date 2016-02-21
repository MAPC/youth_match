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
    best_job = Position.available(@run)
                       .within_reasonable_commute(applicant)
                       .max_by do |position|
      Score.new(applicant: applicant, position: position).score
    end
  end

end

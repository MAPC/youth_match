class MatchJob

  def perform!
    @run = Run.create!
    @run.running!
    Applicant.random.find_each do |applicant|
      break if Position.available(@run).count == 0
      best_job = find_best_job_for(applicant)
      if best_job.nil?
        @run.unplaced << applicant.id
        $logger << 'F'
        next
      end
      @run.placements.create! applicant: applicant, position: best_job
      $logger << '.'
    end
    $logger << "\n"
    $logger.info '----> No more positions available, finishing.'
    @run.succeeded!
  rescue StandardError => e
    puts "\n"
    $logger.error "An error occurred: #{e.message}\n\t#{e.try(:record).inspect}"
    @run.failed!
    raise
  ensure
    @run.failed! if @run.running?
  end

  def find_best_job_for(applicant)
    Position.available(@run).
      within(40.minutes, of: applicant, via: applicant.mode).
      max_by do |position|
        MatchScore.new(applicant: applicant, position: position).score
      end
  end

end

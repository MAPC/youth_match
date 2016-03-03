class MatchJob

  def perform!
    boot!
    Applicant.random.find_each do |applicant|
      break if Position.available(@run).count == 0
      attempt_to_place(applicant)
    end
    successful_shutdown
  rescue StandardError => e
    failing_shutdown(e)
    raise
  ensure
    @run.failed! if @run.running?
    return @run.id
  end

  private

  def boot!
    @run = Run.create!
    @run.running!
  end

  def find_best_job_for(applicant)
    Position.available(@run).
      within(40.minutes, of: applicant, via: applicant.mode).
      max_by do |position|
        MatchScore.new(applicant: applicant, position: position).score
      end
  end

  def attempt_to_place(applicant)
    if best_job = find_best_job_for(applicant)
      @run.placements.create! applicant: applicant, position: best_job
      pass
    else
      @run.unplaced << applicant.id
      fail
    end
  end

  def successful_shutdown
    $logger << "\n"
    $logger.info '----> No more positions available, finishing.'
    @run.succeeded!
  end

  def failing_shutdown(e)
    puts "\n"
    $logger.error "An error occurred: #{e.message}\n\t#{e.try(:record).inspect}"
    @run.failed!
  end

  def pass
    $logger << '.'
  end

  def fail
    $logger << 'F'
  end


end

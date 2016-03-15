class MatchJob

  def perform!(limit=nil)
    boot!
    @limit = limit
    applicants.each_with_index do |id, index|
      break if Position.available(@run).count == 0
      Applicant.find(id).get_a_job!(@run, index)
      log_progress
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

  def applicants
    # nil limit will return all
    Applicant.random.limit(@limit).pluck(:id)
  end

  def successful_shutdown
    log_newline
    msg = if @limit
      "----> Placed #{@limit} applicants, as requested; finishing."
    else
      '----> No more positions available, finishing.'
    end
    $logger.info msg
    @run.succeeded!
  end

  def failing_shutdown(e)
    log_newline
    $logger.fatal "An error occurred: #{e.message}\n\t#{e.try(:record).inspect}"
    @run.failed!
  end

  def log_progress
    $logger << '.'
  end

  def log_newline
    $logger << "\n"
  end

end

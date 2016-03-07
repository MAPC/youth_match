class MatchJob

  def perform!
    boot!
    Applicant.random.pluck(:id).each_with_index do |id, index|
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

  def successful_shutdown
    log_newline
    $logger.info '----> No more positions available, finishing.'
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

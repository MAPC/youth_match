class MatchJob

  def initialize(limit: nil, seed: nil)
    @limit = limit
    @seed = seed || random_seed
  end

  def perform!
    boot!
    log_seed
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
    set_seed
    Applicant.random.limit(@limit).pluck(:id)
  end

  def random_seed
    rand(1000..9999)
  end

  def set_seed
    exec "SELECT setseed(#{@seed/10_000.to_f})"
  end

  def exec(sql)
    ActiveRecord::Base.connection.execute(sql)
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

  def log_seed
    $logger.info "Running with seed #{@seed}"
  end

end

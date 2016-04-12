class LotteryRunJob

  def initialize(run_id: , limit: nil)
    @run = Run.find(run_id)
    @limit = limit
  end

  def perform!
    log_start
    perform
    log_finish
  end

  private

  def perform
    actionable_placements.find_each do |placement|
      pool = placement.pool
      pool.compress! # Add compressed positions before selecting best fit.
      placement.update_attribute(:position, pool.best_fit)
      log_placement(placement)
    end
  end

  def actionable_placements
    @run.placements.
      where(position: nil).
      where(status: :pending).
      order(:id).
      limit(@limit)
  end

  def log_placement(placement)
    print(placement.position ? '.' : 'F')
  end

  def log_start
    count = actionable_placements.count
    msg = "Starting to place #{count} applicants for Run ##{@run.id}"
    msg << " (Given a limit of #{@limit}.)" if @limit
    $logger.info msg
  end

  def log_finish
    $logger.info "Finished placing."
  end

end

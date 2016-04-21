class LotteryRunJob

  def initialize(run_id: , limit: nil)
    @run = Run.find(run_id)
    @limit = limit # Don't convert to integer.
  end

  def perform!
    log_start
    perform
    log_finish
  end

  private

  def perform
    actionable_placement_ids.each do |placement_id|
      placement = Placement.find(placement_id)
      pool = placement.pool
      pool.compress! # Add compressed positions before selecting best fit.
      pool.reload
      begin
        placement.update_attribute(:position, pool.best_fit)
      rescue StandardError => e
        $logger.error "Could not find a best_fit for #{placement.inspect}"
        $logger.error "Pool: #{placement.pool.inspect}"
        $logger.error "Pooled positions: #{placement.pool.pooled_positions.inspect}"
        raise
      end
      log_placement(placement)
    end
  end

  def actionable_placement_ids
    @run.placements.
      where(market: :automatic).where(status: :pending).
      where(position: nil).order(:index).limit(@limit).
      pluck(:id)
  end

  def log_placement(placement)
    print(placement.position ? '.' : "F(#{placement.id})")
  end

  def log_start
    count = actionable_placement_ids.count
    msg = "Starting to place #{count} applicants for Run ##{@run.id}"
    msg << " (Given a limit of #{@limit}.)" if @limit
    $logger.info msg
  end

  def log_finish
    $logger.info "Finished placing."
  end

end

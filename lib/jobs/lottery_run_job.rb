class LotteryRunJob

  def initialize(run_id: , limit: nil)
    @run = Run.find(run_id)
    @limit = limit
  end

  def perform!
    actionable_placements.find_each do |placement|
      pool = placement.pool
      pool.compress! # Add compressed positions before selecting best fit.
      placement.update_attribute(:position, pool.best_fit)
      log_placement(placement)
    end
  end

  private

  def actionable_placements
    @run.placements.
      where(position: nil).
      where(status: :pending)
      order(:id).
      limit(@limit)
  end

  def log_placement(placement)
    if placement.position
      print '.'
    else
      print 'F'
    end
  end

end

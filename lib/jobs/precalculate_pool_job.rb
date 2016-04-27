class PrecalculatePoolJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    auto_placements.find_each do |placement|
      pool = placement.create_pool!
      log_pool(pool)
    end
    msg =  "\nFinished precalculating pools for #{auto_placements.count}"
    msg << " automatic placements for Run #{@run.id}."
    $logger.info msg
  rescue StandardError => e
    $logger.error "#{e}\n#{e.backtrace}"
    false
  end

  private

  def auto_placements
    @run.placements.order(index: :asc).where(market: :automatic)
  end

  def log_pool(pool)
    print(pool.pooled_positions.count > 0 ? '.' : 'F')
  end
end

class PrecalculatePoolJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    msg = "Expected time to completion: "
    msg << "#{(auto_placements.count * 0.62 / 60).round(2)} minutes."
    $logger.warn msg
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
    @run.placements.where(market: :automatic)
  end

  def log_pool(pool)
    print(pool.pooled_positions.count > 0 ? '.' : 'F')
  end
end

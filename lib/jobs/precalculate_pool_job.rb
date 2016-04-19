class PrecalculatePoolJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    msg = "Expected time to completion: "
    msg << "#{(@run.placements.count * 0.62 / 60).round(2)} minutes."
    $logger.warn msg
    @run.placements.find_each do |placement|
      pool = placement.create_pool!
      log_pool(pool)
    end
    msg =  "Finished precalculating pools for #{@run.placements.count}"
    msg << " placements for Run #{@run.id}."
    $logger.info msg
  rescue StandardError => e
    $logger.error "#{e}\n#{e.backtrace}"
    false
  end

  private

  def log_pool(pool)
    print(pool.pooled_positions.count > 0 ? '.' : 'F')
  end
end

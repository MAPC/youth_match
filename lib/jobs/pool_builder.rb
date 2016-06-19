class PoolBuilder

  def initialize(run_id: )
    @run = Run.find(run_id)
    assert_no_pools
  end

  def perform!
    @run.placements.placeable.each do |placement|
      log_pool placement.create_pool!
    end
    $logger.info message
  end

  private

  def log_pool(pool)
    print(pool.pooled_positions.count > 0 ? '.' : 'F')
  end

  def assert_no_pools
    if @run.placements.first.pool.present?
      $logger.error "There are already pools for run #{args[:run_id]}."
      exit 1
    end
  end

  def message
    # TODO Turn this into a query. At the moment, running
    # @run.placements.where.not(pool: nil) is throwing a relation-related error.
    msg =  "\nFinished precalculating pools for #{@run.placements.select(&:pool).count}"
    msg << " automatic placements for Run #{@run.id}."
    msg
  end

end

class PrecalculatePoolJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    @run.placements.find_each do |placement|
      placement.create_pool!
    end
    $logger.info "Finished precalculating pools for #{@run.placements.count} placements for Run ##{@run.id}"
  rescue StandardError => e
    $logger.error "#{e}\n#{e.backtrace}"
    false
  end
end

class LotteryFinalizeJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    @run.placements.where(status: :placed).each do |placement|
      $logger.debug "Syncing placement ##{placement.id} with hiring system."
      begin
        placement.sync!
      rescue StandardError => e
        $logger.error "Could not place #{placement.inspect} because #{e.message}"
        $logger.error e.backtrace.join("\n")
      end
    end
  end

end

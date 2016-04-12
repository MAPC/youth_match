class LotteryFinalizeJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    @run.placements.where(status: 'pending').each do |placement|
      $logger.debug "Finalizing placement ##{placement}"
      begin
        placement.finalize!
      rescue StandardError => e
        $logger.error "Could not place #{placement.inspect} because"
        $logger.error e
        $logger.error e.backtrace.join("\n")
      end
    end
  end

end

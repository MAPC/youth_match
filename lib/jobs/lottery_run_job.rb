class LotteryRunJob

  def initialize(run_id: , limit: nil)
    @run = Run.find(run_id)
    #  TODO: Update config from file.
    @limit = limit # Don't convert to integer, to let nil be nil.
  end

  def perform!
    log_start
    perform
    log_finish
  end

  private

  def perform
    @run.actionable_placement_ids(limit: @limit).each do |placement_id|
      log_placement Placement.find(placement_id).place!
    end
  end

  def log_placement(placement)
    print(placement.reload.position ? '.' : "F(#{placement.id})")
  end

  def log_start
    count = @run.actionable_placement_ids(limit: @limit).count
    msg = "Starting to place #{count} applicants for Run ##{@run.id}"
    msg << " (Given a limit of #{@limit}.)" if @limit
    $logger.info msg
  end

  def log_finish
    $logger.info "Finished placing."
  end

end

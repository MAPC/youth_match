class DeclineRefresher

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    # Run through all the declined positions,
    # duplicating them so the applicants have another chance.
    @run.refreshable_declined_placements.each do |declined|
      placement = @run.placements.create! duplicate(declined)
      placement.pool = declined.pool.dup if declined.pool
    end
    $logger.info message
  end

  def duplicate(placement)
    {
      applicant: placement.applicant,
      index:     placement.index,
      market:    placement.market
    }
  end

  def message
    msg = "Refreshed #{@run.refreshable_declined_placements.count}"
    msg << " declined placements for Run ##{@run.id}"
    msg
  end

end

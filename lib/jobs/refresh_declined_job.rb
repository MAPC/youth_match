class RefreshDeclinedJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    # Run through all the declined positions, duplicating them so the
    # applicants have another chance.
    @run.refreshable_declined_placements.each do |p|
      placement = @run.placements.create!(applicant: p.applicant,
        index: p.index, market: p.market )
      placement.pool = p.pool.dup if p.pool
    end
    $logger.info "Refreshed #{@run.refreshable_declined_placements.count} declined placements for Run ##{@run.id}"
  end

end

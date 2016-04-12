class RefreshDeclinedJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    # Run through all the declined positions,
    # duplicating them so the applicants have another chance.
    declined_placements = @run.placements.where(status: :declined)
    declined_placements.each do |p|
      if decline_count(p.applicant) < 2
        Placement.create! applicant: p.applicant, index: p.index
      end
    end
    $logger.info "Refreshed #{declined_placements.count} declined placements for Run ##{@run.id}"
  end

  private

  def decline_count(applicant)
    @run.placements.
      where(applicant: applicant).
      where(status: :declined).
      count
  end

end

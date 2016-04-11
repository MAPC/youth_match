class RefreshDeclinedJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    # Run through all the declined positions,
    # duplicating them so the applicants have another chance.
    @run.placements.where(status: :declined).each do |p|
      if decline_count(p.applicant) < 2
        Placement.create! applicant: p.applicant, index: p.index
      end
    end
  end

  private

  def decline_count(applicant)
    @run.placements.
      where(applicant: applicant).
      where(status: :declined).
      count
  end

end

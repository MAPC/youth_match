class ExpirationChecker

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    # Run through all placed & synced positions and set them to expired.
    already = @run.placements.where(status: :expired).count
    counter = 0
    @run.placements.where(status: [:placed, :synced]).each do |placement|
      if placement.expired?
        placement.applicant.update_attribute(:status, :opted_out)
        counter += 1
      end
    end
    $logger.info "Set #{counter} placements to expired, #{already} already expired for Run ##{@run.id}"
  end
end

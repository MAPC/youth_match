class AssignTicketsJob

  def initialize(seed: nil)
    @run = Run.create!(seed: seed)
  end

  def perform!
    # We use the pluck method instead of #find_each because #find_each
    # orders by ID, removing the random ordering.
    Applicant.random.pluck(:id).each_with_index do |id, index|
      begin
        @run.placements.create(applicant_id: id, index: (index + 1))
      rescue => e
        $logger.warn "Cannot find Applicant #{id}, skipping."
        $logger.warn "#{e}"
      end
    end
    $logger.debug "Finished setting up Run ##{@run.id}"
    return @run
  end
end

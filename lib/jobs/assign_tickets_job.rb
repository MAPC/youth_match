class AssignTicketsJob

  def initialize(seed: nil)
    @run = Run.create!(seed: seed)
  end

  def perform!
    # We use the pluck method instead of #find_each because #find_each
    # orders by ID, removing the random ordering.
    Applicant.random.pluck(:id).each_with_index do |id, index|
      begin
        @run.placements.create(
          applicant_id: id,
          index: (index + 1),
          market: markets.sample
        )
      rescue => e
        $logger.warn "Cannot find Applicant #{id}, skipping."
        $logger.warn "#{e}"
      end
    end
    log_stats
    return @run
  end

  private

  def markets
    Placement.market.values
  end

  def log_stats
    denom = @run.placements.count.to_f
    automatic = (@run.placements.where(market: 'automatic') / denom) * 100
    manual = (@run.placements.where(market: 'manual') / denom) * 100
    stats = "Automatic: #{automatic.round(2)} %\nManual: #{manual.round(2)} %"
    fin = "Finished setting up assigning tickets and markets for run #{@run.id}"
    $logger.info stats
    $logger.debug fin
  end
end

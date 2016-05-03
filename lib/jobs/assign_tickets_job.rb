class AssignTicketsJob

  def initialize(seed: nil)
    @run = Run.create!(seed: seed)
  end

  def perform!
    @run.applicants.each do |applicant|
      @run.placements.create!(
        applicant_id: applicant.id,
        index:        applicant.index,
        market:       applicant.market
      )
    end
    log_stats
    return @run
  end

  private

  def log_stats
    denom     = @run.placements.count.to_f
    auto_num  = @run.placements.where(market: 'automatic').count
    man_num   = @run.placements.where(market: 'manual').count
    automatic = (auto_num / denom) * 100
    manual    =  (man_num / denom) * 100

    stats = "\nAutomatic: #{automatic.round(2)} %\t(#{auto_num})"
    stats << "\nManual: #{manual.round(2)} %\t(#{man_num})"
    fin = "Finished setting up assigning tickets and markets for run #{@run.id}"
    $logger.info stats
    $logger.debug fin
  end
end

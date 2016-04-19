class CheckJob

  def initialize(run_id: )
    @run = Run.find(run_id)
  end

  def perform!
    $logger.info '----> Running checks'
    assert_present :applicants
    assert_present :positions
    assert_grid_ids :applicants
    assert_grid_ids :positions
    assert_position_markets
    assert_placement_markets

  end

  private

  def assert_present(plural_name)
    klass = plural_name.to_s.classify.constantize
    if (count = klass.count) > 0
      $logger.info "----> #{count} #{plural_name} present #{checkmark}"
    else
      $logger.error "----> FAIL: No #{plural_name} present."
      exit 1
    end
  end

  def assert_grid_ids(plural_name)
    klass = plural_name.to_s.classify.constantize
    if (count = klass.where(grid_id: nil).count) == 0
      $logger.info "----> No #{plural_name} missing grid IDs."
    else
      $logger.error "----> FAIL: #{count} #{plural_name} missing grid IDs."
      exit 1
    end
  end

  def assert_position_markets
    if Position.where.not(automatic: nil).count == Position.all.count
      $logger.info "----> All positions have markets. #{checkmark}"
    else
      msg =  "FAIL: Not all positions have a market: "
      msg << "#{Position.where(automatic: nil).count} need markets"
      $logger.error "----> #{msg}"
      exit 1
    end
  end

  def assert_placement_markets
    if @run.placements.where.not(market: nil).count == @run.placements.count
      $logger.info "----> All placements in run #{@run.id} have markets. #{checkmark}"
    else
      msg =  "FAIL: Not all placements have a market: "
      msg << "#{@run.placements.where(market: nil).count} need markets"
      $logger.error "----> #{msg}"
      exit 1
    end
  end

  def checkmark
    "\u2713"
  end

end

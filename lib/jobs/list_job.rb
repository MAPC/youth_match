class ListJob

  def perform!
    if Run.count == 0
      $logger.warn "There are no runs to display. Run `rake match:run` to create a run."
    else
      list_runs
    end
  end

  private

  def list_runs
    $logger.info "\nAll Runs\n------------------\nID\tSTATUS\tCREATED AT"
    Run.order(created_at: :desc).find_each do |run|
      $logger.info "#{run.id}:\t#{run.status}\t#{run.created_at}"
    end
  end

end

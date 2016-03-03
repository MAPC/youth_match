class ListJob

  def perform!
    if Run.count == 0
      puts "There are no runs to display. Run `rake match:run` to create a run."
    else
      list_runs
    end
  end

  private

  def list_runs
    puts "\nAll Runs\n------------------\nID\tSTATUS\tCREATED AT"
    Run.order(created_at: :desc).find_each do |run|
      puts "#{run.id}:\t#{run.status}\t#{run.created_at}"
    end
  end

end

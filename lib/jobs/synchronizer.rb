class Synchronizer

  def initialize(run_id: , dry_run: false, limit: nil, offset: nil)
    @run = Run.find(run_id)
    @dry_run = dry_run.to_b
    @limit = limit
    @offset = offset
  end

  def perform
    synchronizable_placements.each do |placement|
      log_each placement
      next if check_dry_run
      attempt_to_sync placement
    end
  end

  def dry_run?
    @dry_run
  end

  def synchronizable_placements
    @run.placements.placed.limit(@limit).offset(@offset)
  end

  private

  # Expecting this to be error-prone. Might have more insight on how to
  # rewrite in Confident style after a few trials.
  def attempt_to_sync(placement)
    begin
      unless placement.push! # to ICIMS
        raise StandardError, unplaceable_message(placement)
      end
    rescue StandardError => e # Catches sync errors and the raise upon false
      log_error(e, placement)
    end
  end

  # If it's a dry run, logs it and returns true for `next`.
  def check_dry_run
    if @dry_run
      $logger.info ":: dry run, did not sync with ICIMS"
      return true
    end
  end

  def unplaceable_message(placement)
    msg = "could not place #{placement.inspect},"
    msg << " position: #{placement.position_id.inspect}"
    msg
  end

  def log_each(placement)
    $logger.debug "Syncing placement #{placement.id} with hiring system."
  end

  def log_error(error, placement)
    $logger.error "Could not place #{placement.id}:\n\t #{error.message}"
    $logger.error error.backtrace.join("\n")
    $logger.error placement.inspect
  end

end


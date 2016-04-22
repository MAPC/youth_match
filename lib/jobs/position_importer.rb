class PositionImporter

  attr_reader :limit, :offset

  def initialize(limit: nil, offset: 0, continue: true)
    @limit = limit ? limit.to_i : nil
    @offset = offset.to_i
    @continue = continue.to_b
  end

  def perform!
    ICIMS::Job.eligible(scope_opts) do |job|
      next if skip_duplicate? job
      job.address # Invoke to ensure address is added to attributes.
      position = Position.create_from_icims(job)
      $logger.debug "Created position #{position.id}."
    end
    true
  end

  def skip_duplicate?(job)
    if j = Position.find_by(id: job.id)
      $logger.info "----> Skipping #{job.id} because Position #{j.id} exists"
      true
    end
  rescue
    false
  end

  def scope_opts
    { limit: @limit, offset: @offset }
  end

end

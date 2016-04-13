class ApplicantImporter

  attr_reader :limit, :offset

  def initialize(limit: nil, offset: 0, continue: true)
    @limit = limit ? limit.to_i : nil
    @offset = offset.to_i
    @continue = continue.to_b
  end

  def perform!
    ICIMS::Workflow.eligible(scope_opts) do |workflow|
      next if skip_duplicate? workflow
      $logger.debug "About to create Applicant from workflow ##{workflow.inspect}"
      person = workflow.person
      person.address # Invoke to ensure it's in attributes
      applicant = Applicant.create_from_icims(workflow.person)
    end
    true
  end

  def skip_duplicate?(workflow)
    if app = Applicant.find_by(id: workflow.person_id)
      $logger.info "----> Skipping workflow #{workflow.id} because Applicant #{app.id} exists"
      true
    end
  rescue
    false
  end

  def scope_opts
    { limit: @limit, offset: @offset }
  end

end

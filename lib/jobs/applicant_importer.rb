class ApplicantImporter

  attr_reader :limit, :offset

  def initialize(limit: nil, offset: 0, continue: true)
    @limit = limit
    @offset = offset
  end

  def perform!
    ICIMS::Workflow.eligible(scope_opts) do |workflow|
      next if skip_duplicate? workflow
      Applicant.create_from_icims(workflow.person)
    end
    true
  end

  def skip_duplicate?(workflow)
    if app = Applicant.find_by(id: workflow.person_id)
      $logger.info "----> Skipping #{workflow.id} because Applicant #{app.id} exists"
      true
    end
  rescue
    false
  end

  def scope_opts
    { limit: @limit, offset: @offset }
  end

end

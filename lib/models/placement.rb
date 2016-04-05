class Placement < ActiveRecord::Base

  extend Enumerize

  belongs_to :run
  belongs_to :applicant
  belongs_to :position

  validates :run,       presence: true
  validates :applicant, presence: true
  validates :index,     presence: true

  enumerize :status, in: [:pending, :placed, :accepted, :declined, :expired],
    default: :pending, predicates: true

  def finalize!
    if workflow = create_workflow
      self.status = :placed
      self.workflow_id = workflow.id
      save
    end
  end

  def updatable?
    !already_decided?
  end

  def accepted
    # Test the new conditionals
    # If there's no workflow, just do it anyway
    update_attribute(:status, :accepted) if workflow.accepted
  end

  def declined
    update_attribute(:status, :declined) if workflow.declined
  end

  def placed
    update_attribute(:status, :placed)
  end

  def expired
    # TODO figure out when to check this.
    update_attribute(:status, :expired)
  end

  def workflow
    @workflow ||= if workflow_id
      ICIMS::Workflow.find(workflow_id)
    else
      ICIMS::Workflow.null
    end
  end

  def travel_time
    return nil if position.nil? # May have introduced a stats bug
    TravelTime.where(
      target_id: position.grid_id,
      input_id: applicant.grid_id,
      travel_mode: applicant.mode
    ).first.time
  end

  def already_decided?
    decided? || workflow.decided?
  end

  private

  def decided?
    [:accepted, :declined].include?(status.to_sym)
  end

  def create_workflow
    ICIMS::Workflow.create({ job_id: position.id, person_id: applicant.id,
      status: 'PLACED' })
  end

end

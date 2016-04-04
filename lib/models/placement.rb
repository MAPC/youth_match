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

  def accepted
    update_attribute(:status, :accepted)
  end

  def declined
    update_attribute(:status, :declined)
  end

  def placed
    update_attribute(:status, :placed)
  end

  def expired
    update_attribute(:status, :expired)
  end

  def workflow
    return nil unless workflow_id
    @workflow ||= ICIMS::Workflow.find(workflow_id)
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
    decided_locally? || decided_remotely?
  end

  private

  def decided_locally?
    [:accepted, :declined].include?(status.to_sym)
  end

  def decided_remotely?
    return false unless workflow
    ['C36951', 'C14661'].include?(workflow.status)
  end

  def create_workflow
    ICIMS::Workflow.create({ job_id: position.id, person_id: applicant.id,
      status: 'PLACED' })
  end

end

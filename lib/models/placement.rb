class Placement < ActiveRecord::Base

  extend Enumerize

  belongs_to :run
  belongs_to :applicant
  belongs_to :position

  validates :run,       presence: true
  validates :applicant, presence: true
  validates :index,     presence: true

  enumerize :status, in: [:pending, :placed, :accepted, :declined, :expired],
    default: :pending, predicates: { except: [:expired] }

  def finalize!
    placed(workflow: create_workflow)
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

  def placed(workflow: )
    update_attributes(
      status: :placed,
      expires_at: expiration_date,
      workflow_id: workflow.id
    )
  end

  def expired?
    status == 'expired' || check_expired
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

  def expiration_date
    # The next Friday we assign people to must be 4 days from now.
    # If it's Monday, the next Friday should be that week.
    # If it's Tuesday, it must be the next week's Friday.
    min_days_from_now = 4
    max_days_from_now = 10
    range = (min_days_from_now..max_days_from_now).to_a
    date = range.map.select { |i| i.days.from_now.friday? }.last.days.from_now
    Time.new(date.year, date.month, date.day, 17)
  end

  private

  def check_expired
    if expires_at && Time.now > expires_at
      update_attribute(:status, :expired)
    end
  end

  def decided?
    [:accepted, :declined].include?(status.to_sym)
  end

  def create_workflow
    ICIMS::Workflow.create({ job_id: position.id, person_id: applicant.id,
      status: ICIMS::Status.placed })
  end

end

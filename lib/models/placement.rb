class Placement < ActiveRecord::Base

  extend Enumerize

  after_save :opt_out_applicant
  after_save :check_position_available

  belongs_to :run
  belongs_to :applicant
  belongs_to :position
  has_one :pool, dependent: :destroy

  validates :run,       presence: true
  validates :applicant, presence: true
  validates :index,     presence: true
  validates :market,    presence: true

  validate :expires_at_in_past, if: -> { status == 'expired' }

  enumerize :status, in: [
    :pending,  # A new placement, that hasn't been given a position.
    :placed,   # Assigned a position, but not synced with the hiring system.
    :synced,   # Assigned a position and synced with the hiring system.
    :accepted, # Applicant received an email and clicked 'Accept' for this offer.
    :declined, # Applicant received an email and clicked 'Decline' for this offer.
    :expired   # Applicant received an email but did not respond in time.
  ],
  default: :pending, predicates: { except: [:expired] }

  enumerize :market, in: [:automatic, :manual], predicates: false

  default_scope {
    order(index: :asc).where(market: :automatic)
  }

  def place!
    pool.compress! # Add compressed positions before selecting best fit.
    pool.reload    # Not sure we need this, but it seemed like it at the time.
    if best_job = pool.best_fit
      update_attributes(position: best_job, status: :placed)
    end
    return self
  end

  def unplace!
    update_attributes(
      position_id: nil, workflow_id: nil, expires_at: nil, status: :pending
    )
  end

  def push!
    return false unless syncable?
    update_attributes(
      status:      :synced,
      expires_at:  expiration_date,
      workflow_id: create_workflow.id # Creates hiring system workflow
    )
  end

  def pull!
    self.status = if workflow.accepted?
      :accepted
    elsif workflow.declined?
      :declined
    elsif workflow.expired?
      :expired
    elsif workflow.placed?
      :placed
    else
      $logger.error "workflow status for #{id} is #{workflow.status}"
    end
    save!
  end

  def syncable?
    position_id.present?
  end

  def self.placed
    where(status: :placed)
  end

  def self.placeable
    where(market: :automatic, status: :pending, position: nil).
      order(index: :asc)
  end

  def self.declined_refreshable(run: )
    includes(:applicant).where(status: :declined).
      where.not(applicants: { status: :opted_out }).
      select do |p|
        p.applicant.placements_for_run(run).count < 2
      end
  end

  def self.exportable
    includes(:applicant, :position).
      where(status: [:placed, :synced]). # Disallow pending placements
      where.not(position_id: nil).       # Redundant
      order(index: :asc) # Redundant with default_scope
  end

  def self.unavailable
    where status: [:placed, :synced, :accepted]
  end

  def updatable?
    !already_decided? && workflow.updatable?
  end

  def accepted
    if workflow.accepted
      update_attribute(:status, :accepted)
    end
  end

  def declined
    if workflow.declined
      update_attribute(:status, :declined)
    end
  end

  def opted_out
    declined
    applicant.opted_out
  end

  def expired?
    status == 'expired' || check_expired
  end

  def expire!
    if workflow.expired
      update_attribute :status, :expired
    end
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
    TravelTime.find_by(input_id: applicant.grid_id,
      target_id: position.grid_id, travel_mode: applicant.mode).time
  end

  def already_decided?
    decided? || workflow.decided?
  end

  def last_chance?
    self.class.where(
      applicant_id: self.applicant_id,
      run_id: self.run_id,
      status: :declined
    ).any? # Not super precise?
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

  def opt_out_applicant
    if applicant.placements.where(status: :declined).count >= 2
      applicant.update_attribute(:status, :opted_out)
    end
  end

  def check_position_available
    position.check_availability(run) if position
  end

  def expires_at_in_past
    unless expires_at.past?
      errors.add(:expires_at, 'must be in the past when status is "expired"')
    end
  end

  def check_expired
    if expires_at && Time.now > expires_at
      update_attribute(:status, :expired)
      applicant.update_attribute(:status, :opted_out)
    end
  end

  def decided?
    [:accepted, :declined].include?(status.to_sym)
  end

  def create_workflow
    ICIMS::Workflow.create({
      job_id:    position.id,
      person_id: applicant.id,
      status:    ICIMS::Status.placed
    })
  end

  def log_no_best_fit
    $logger.error "Could not find a best_fit for #{self.inspect}"
    $logger.error "Pool: #{pool.inspect}"
    $logger.error "Pooled positions: #{pool.pooled_positions.inspect}"
  end

end

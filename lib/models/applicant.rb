class Applicant < ActiveRecord::Base

  include Locatable
  include CreatableFromICIMS

  extend Enumerize

  before_validation :compute_grid_id
  before_save :assign_mode

  validates :grid_id, presence: true

  enumerize :status, in: [:pending, :activated, :onboarded, :opted_out],
    default: :pending, predicates: true

  def opted_out
    update_attribute(:status, :opted_out)
  end

  def mode
    if has_transit_pass_changed?
      convert_pass_to_mode
    else
      read_attribute :mode
    end
  end

  def interests
    Array(read_attribute(:interests))
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

  # Requires a lot of collaborators and information to test.
  # This may not be the best architecture, but it works for now.
  # At its best, from a critical code perspective, it reflects
  # the autonomy and agency of the job-seeker.
  def get_a_job!(run, index)
    # TODO
    # run.placements.create position: Pool.new(self).best_job, applicant: self
    best_job, opps = JobFinder.new(applicant: self, run: run).best_job_and_opportunities
    params = { applicant: self, index: index, position: best_job,
      opportunities: opps }
    run.placements.create! params
  end

  private

  def convert_pass_to_mode
    has_transit_pass? ? 'transit' : 'walking'
  end

  def assign_mode
    self.mode = convert_pass_to_mode
  end

end

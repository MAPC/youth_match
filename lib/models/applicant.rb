class Applicant < ActiveRecord::Base

  include Locatable

  before_validation :compute_grid_id
  before_save :assign_mode

  validates :grid_id, presence: true

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

  def get_a_job!(run, index)
    best_job, opps = JobFinder.new(self, run).best_job
    params = { run: run, index: index, position: best_job,
      opportunities: opps }
    self.placements.create! params
  end

  private

  def convert_pass_to_mode
    has_transit_pass? ? 'transit' : 'walking'
  end

  def assign_mode
    self.mode = convert_pass_to_mode
  end

end

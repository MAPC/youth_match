class Applicant < ActiveRecord::Base

  include Locatable

  before_validation :compute_grid_id
  validates :grid_id, presence: true

  def mode
    # computing this on the fly makes it hard to query
    has_transit_pass? ? :transit : :walking
  end

  def interests
    Array(read_attribute(:interests))
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

end

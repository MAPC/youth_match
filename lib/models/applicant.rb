class Applicant < ActiveRecord::Base

  include Locatable

  before_validation :compute_grid_id
  validates :grid_id, presence: true

  def mode
    # Computing this on the fly makes it hard to query.
    # We could easily do this in a before_save, adding it
    # as a queryable field to Applicant.
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

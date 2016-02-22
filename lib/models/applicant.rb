class Applicant < ActiveRecord::Base
  def self.random
    order('RANDOM()')
  end

  def grid_id
    # TODO
  end

  def location
    # TODO [y, x]
  end

  def mode
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

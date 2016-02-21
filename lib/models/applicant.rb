class Applicant < ActiveRecord::Base
  def self.random
    order('RANDOM()')
  end

  # TODO: Should there be a #location method populated with the
  #       coordinates from geocoding, which is used in a spatial
  #       lookup to find the grid cell, or should
  #       there only be a #grid_id method, and we determine the grid
  #       cell ID during the geocoding process?

  def interests
    Array(read_attribute(:interests))
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest
end

class Position < ActiveRecord::Base

  # TODO: Same question as applicant: coordinates + spatial lookup,
  #       or grid cell ID?

  def self.available(run)
    # where not in run.placements
  end

  def self.within_reasonable_commute(applicant)
    # where lookup grid cells, travel time between
    # applicant and position is less than 40 minutes
  end
end

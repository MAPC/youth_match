class Position < ActiveRecord::Base
  def self.available(run)
    # where not in run.placements
  end

  def self.within_reasonable_commute(applicant)
    # where lookup grid cells, travel time between
    # applicant and position is less than 40 minutes
  end
end

class Position < ActiveRecord::Base

  # TODO: Same question as applicant: coordinates + spatial lookup,
  #       or grid cell ID?

  # TODO: This logic might also be useful the other way around.
  #       Should write it as a module, and include it
  def self.available(run)
    # where not in run.placements
  end

  def self.within(time = 40.minutes, of: , via: :walking)
    # TODO: Guard that given object has grid_id.
    # where lookup grid cells, travel time between
    # applicant and position is less than time given
    time = time.to_i
  end
end

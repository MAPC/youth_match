class Position < ActiveRecord::Base

  def grid_id
    # TODO
  end

  def location
    # TODO [y, x]
  end

  def self.available(run)
    # where not in run.placements
  end

  def self.within(time = 40.minutes, of: , via: :walking)
    # TODO: Guard that given object has grid_id.
    # where lookup grid cells, travel time between
    # applicant and position is less than time given
    time = time.to_i
    grid_id = Grid.find_by_sql("SELECT ST_Intersects(geom, #{of})").id
    TravelTime.where(origin_id: grid_id).where("time < #{time}")
  end
end

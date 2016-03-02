module Locatable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def random
      order('RANDOM()')
    end

    def within(time = 40.minutes, of: , via: :walking)
      destination, mode = of, via # clearer aliases
      ids = destination.
        travel_times.
        where(travel_mode: mode).
        where("time <= #{time.to_i}").
        pluck(:target_id).uniq
      self.where(grid_id: ids)
    end
  end

  def travel_times
    TravelTime.where(input_id: grid_id)
  end

  private

  def compute_grid_id
    grid = Grid.intersecting_grid(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end

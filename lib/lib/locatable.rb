module Locatable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def random
      order('RANDOM()')
    end

    def within(time = 40.minutes, of: , via: :walking)
      # TOOO: test this
      ids = of.travel_times.
              where(travel_mode: via).
              where("time < #{time.to_i}").
              pluck(:target_id). # .select(:target_id).distinct
              uniq

      self.where(grid_id: ids)
    end
  end

  def travel_times
    TravelTime.where(input_id: grid_id)
  end

  def within?(time = 40.minutes, of: , via: :walking)
    # where lookup grid cells, travel time between
    # applicant and position is less than time given
    time = time.to_i
    travel_times.where(travel_mode: via)
                .where("time < #{time}")
                .exists?(target_id: of.grid_id)
  end

  private

  def compute_grid_id
    grid = Grid.intersecting_grid(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end

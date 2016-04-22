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

  def within?(time = 40.minutes, of: , via: :walking)
    # adding this method back in after it was removed
    # this is going to be useful for summary stats...
    destination, mode = of, via # clearer aliases
    time = time.to_i
    travel_times.where(travel_mode: mode)
                .where("time < #{time}")
                .exists?(target_id: destination.grid_id)
  end

  def address
    ICIMS::Address.new(addresses)
  end

  delegate :street, :city, :state, :zip, :zip_5, to: :address

  private

  def compute_grid_id
    grid = Grid.intersecting_grid(location: location)
    self.grid_id = grid.g250m_id if grid
  end
end

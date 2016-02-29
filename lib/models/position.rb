class Position < ActiveRecord::Base

  before_validation :compute_grid_id

  # A computed grid_id must be present
  validates :grid_id, presence: true

  def travel_times
    TravelTime.where(input_id: grid_id)
  end

  def self.random
    order('RANDOM()')
  end

  def self.available(run)
    # where not in run.placements -- there's probably a prettier way
    where("id not in (:placements)", placements: run.placements.pluck(:position_id))
  end

  def within?(time = 40.minutes, of: , via: :walking)
    # TODO: Guard that given object has grid_id.
    # where lookup grid cells, travel time between
    # applicant and position is less than time given
    time = time.to_i
    travel_times.where(travel_mode: via)
                .where("time < #{time}")
                .exists?(target_id: of.grid_id)
  end

  def self.within(time = 40.minutes, of: , via: :walking)
    # TODO: Guard that given object has grid_id.
    time = time.to_i
    ids = of.travel_times
            .where(travel_mode: via)
            .where("time < #{time}")
            .pluck(:target_id)
            .uniq

    self.where(grid_id: ids)
  end

  private 

    def compute_grid_id
      grid = Grid.intersecting_grid(location: location)
      self.grid_id = grid.g250m_id if grid
    end
end

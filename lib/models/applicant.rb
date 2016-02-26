class Applicant < ActiveRecord::Base

  before_validation :compute_grid_id

  # A computed grid_id must be present
  validates :grid_id, presence: true

  def travel_times
    TravelTime.where(input_id: grid_id)
  end

  def self.random
    order('RANDOM()')
  end

  def mode
    # computing this on the fly makes it hard to query
    has_transit_pass? ? :transit : :walking
  end

  def interests
    Array(read_attribute(:interests))
  end

  def prefers_interest
    !prefers_nearby
  end
  alias_method :prefers_interest?, :prefers_interest

  private 

    def compute_grid_id
      @grid = Grid.intersecting_grid(location: location)
      self.grid_id = @grid.g250m_id if @grid
    end
end

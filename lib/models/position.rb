class Position < ActiveRecord::Base

  include Locatable

  before_validation :compute_grid_id
  validates :grid_id, presence: true

  def self.available(run)
    where.not(id: run.placements.pluck(:position_id))
  end

end

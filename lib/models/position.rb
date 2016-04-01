class Position < ActiveRecord::Base

  include Locatable
  include CreatableFromICIMS

  before_validation :compute_grid_id
  validates :grid_id, presence: true, if: 'location.present?'

  def self.available(run)
    where.not(id: run.placements.pluck(:position_id))
  end

end

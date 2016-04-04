class Position < ActiveRecord::Base

  include Locatable
  include CreatableFromICIMS

  before_validation :compute_grid_id
  validates :grid_id, presence: true, if: 'location.present?'

  def self.base_pool_for(applicant, run)
    # Includes travel time via #pool_for
    pool_for(applicant, run).where(reserve: false)
  end

  def self.reserve_pool_for(applicant, run)
    # Doesn't include travel time
    available(run).where(reserve: true)
  end

  def self.pool_for(applicant, run)
    available(run).
    within(40.minutes, of: applicant, via: applicant.mode)
  end

  def self.available(run)
    where.not(id: run.placements.pluck(:position_id))
  end

end

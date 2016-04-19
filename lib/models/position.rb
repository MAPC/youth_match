require './lib/lib/locatable'
require './lib/lib/creatable_from_icims'

class Position < ActiveRecord::Base

  include Locatable
  include CreatableFromICIMS

  before_validation :compute_grid_id, if: 'location.present?'
  validates :grid_id, presence: true, if: 'location.present?'

  validate :position_counts, if: 'manual? || automatic?'

  validates :automatic, presence: true, numericality: true, if: 'manual.present?'
  validates :manual,    presence: true, numericality: true, if: 'automatic.present?'

  def available?(run)
    positions > run.placements.where(position: self).count
  end

  def self.compressible(run)
    # May want to order by applicant distance in the future
    available(run).where(reserve: true).order('RANDOM()')
  end

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

  private

  def position_counts
    if manual? && automatic?
      unless manual + automatic == positions
        msg =  "must be equal to the sum of automatic (#{automatic.inspect})"
        msg << " and manual (#{manual.inspect}) positions,"
        msg << " but was #{positions}"
        errors.add(:positions, msg)
      end
    end
  end


end

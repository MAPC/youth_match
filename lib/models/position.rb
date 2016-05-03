require './lib/lib/locatable'
require './lib/lib/creatable_from_icims'

class Position < ActiveRecord::Base

  include Locatable
  include CreatableFromICIMS

  has_many :placements

  before_validation :compute_grid_id, if: 'location.present?'
  validates :grid_id, presence: true, if: 'location.present?'

  validates :positions, presence: true, numericality: { minimum: 0 }, if: 'manual? || automatic?'
  validate  :position_counts, if: 'manual? || automatic?'
  validates :automatic, presence: true, numericality: { minimum: 0 }, if: 'manual.present?'
  validates :manual,    presence: true, numericality: { minimum: 0 }, if: 'automatic.present?'

  def available?(run)
    automatic.to_i > self.placements.
      where(run: run).
      where(market: :automatic).
      where(status: [:accepted, :placed, :synced]).
      count
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
    where(id: run.available_positions)
  end

  def check_availability(run)
    if automatic.to_i > taken_placements(run).count
      run.add_to_available self
    else
      run.remove_from_available self
    end
  end

  def taken_placements(run)
    run.unavailable_placements.where(position_id: self.id)
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

  # def self.available_query(run)
  #   query = %Q{ , (
  #     SELECT "placements"."position_id", COUNT("placements"."position_id")
  #       FROM "placements"
  #       WHERE "run_id" = #{run}
  #       AND "status" IN ('placed', 'synced', 'accepted')
  #       GROUP BY "placements"."position_id"
  #     ) AS c
  #     WHERE positions.id = c.position_id
  #     AND   positions.automatic > c.count
  #     ORDER BY positions.id
  #   }
  # end

end

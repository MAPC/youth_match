class Pool < ActiveRecord::Base

  before_save :count_positions # Awkward ordering, but gets it done.
  after_save :allocate_positions

  belongs_to :placement
  has_and_belongs_to_many :pooled_positions, join_table: :pooled_positions,
    class_name: 'PooledPosition', association_foreign_key: :position_id

  validates :placement, presence: true

  delegate :applicant, to: :placement
  delegate :run,       to: :placement

  def positions
    pooled_positions
  end

  def best_fit
    return nil if positions.count == 0
    positions.order_by { |p| p.score.total }.detect do |position|
      position.positions > placements_with(position)
    end
  end

  # This would add the compression too early, because we're precalculating
  # the base pools and basing RUNTIME compression off of that.
  # So we need to allocate base positions first, then add compressed positions
  # at runtime to balance out the effects of the randomness on removing jobs
  # from the base pools.
  def compress!
    c = Compressor.new(self).positions.map do |position|
      PooledPosition.create(pool: self, position: position, compressed: true)
    end
    $logger.debug "Added #{c.count} positions to pool ##{id}."
  end

  private

  def count_positions
    self.position_count = Position.base_pool_for(applicant, run).count
  end

  def allocate_positions
    Position.base_pool_for(applicant, run).each do |position|
      self.pooled_positions.create!(position: position, pool: self)
    end
  end

  def placements_with(position)
    run.placements.where(position: position).count
  end

end

class Pool < ActiveRecord::Base

  before_save :count_positions # Awkward ordering, but gets it done.
  after_save :allocate_positions

  belongs_to :applicant
  belongs_to :run
  has_and_belongs_to_many :pooled_positions, join_table: :pooled_positions,
    class_name: 'PooledPosition', association_foreign_key: :position_id

  def positions
    pooled_positions
  end

  validates :applicant, presence: true
  validates :run, presence: true
  # validates unique within applicant_id, run_id

  def best_fit
    return nil if positions.count == 0
    best_job_id = positions.max_by { |p| p.score.total }
    # TODO: Ensure position is available in run scope before selecting!!!!
    #  Order by score, select until one is available
    Position.find(best_job_id)
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

  # This would add the compression too early, because we're precalculating
  # the base pools and basing RUNTIME compression off of that.
  # So we need to allocate base positions first, then add compressed positions
  # at runtime to balance out the effects of the randomness on removing jobs
  # from the base pools.
  def compress!
    Compressor.new(self).positions.map do |position|
      PooledPosition.create(compressed: true, run: run,
        applicant: applicant, position: position,)
    end.count
  end

end

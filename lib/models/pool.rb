class Pool < ActiveRecord::Base

  before_save :allocate_positions

  belongs_to :applicant
  belongs_to :run
  has_and_belongs_to_many :positions, join_table: :pooled_positions

  validates :applicant, presence: true
  validates :run, presence: true

  def best_fit
    return nil if positions.count == 0
    best_job_id = positions.max_by { |p| p.score.total }
    Position.find(best_job_id)
  end

  private

  def allocate_positions
    self.positions = base_pool
    self.base_proportion = calculate_base_proportion

    self.positions << Compressor.new(self).positions
    self.position_count = self.positions.count
  end

  def calculate_base_proportion
    (self.positions.count / Pool.maximum(:position_count)) * 100
  rescue
    0
  end

  def base_pool
    Position.base_pool_for(applicant, run).map do |position|
      PooledPosition.create(applicant: applicant, position: position, run: run)
    end
  end

end

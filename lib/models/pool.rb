class Pool < ActiveRecord::Base

  before_save :allocate_positions

  belongs_to :applicant
  belongs_to :run
  has_and_belongs_to_many :positions # May want to simulate with an array.

  validates :applicant, presence: true
  validates :run, presence: true

  def best_fit
    return nil if positions.count == 0
    best_job_id = positions.max_by { |p| p.score.total }
    Position.find(best_job_id)
  end

  def base_proportion
    (positions.count / Pool.max(:position_count).to_f) * 100
  end

  private

  def allocate_positions
    self.positions = base_pool
    self.positions << Compressor.new(self).positions
  end

  def base_pool
    Position.available(@run).
      where(reserve: false)
      within(40.minutes, of: @applicant, via: @applicant.mode).
      map do |position|
        # Not sure about this extra entity.
        ScoredPosition.create(applicant: applicant, position: position, run: run)
      end
  end
end

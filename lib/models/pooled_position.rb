class PooledPosition < ActiveRecord::Base

  before_save :set_score

  belongs_to :pool
  belongs_to :position

  delegate :applicant, to: :pool
  delegate :run, to: :pool

  delegate :available?, to: :position

  validates :pool, presence: true
  validates :position, presence: true, uniqueness: { scope: :pool }

  private

  def set_score
    self.score = MatchScore.new(applicant: applicant, position: position).to_h
  end
end

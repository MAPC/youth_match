class PooledPosition < ActiveRecord::Base

  before_save :set_score

  belongs_to :pool
  belongs_to :position

  delegate :applicant, to: :pool
  # delegate :run, to: :pool

  validates :pool, presence: true
  validates :position, presence: true

  private

  def set_score
    self.score = MatchScore.new(applicant: applicant, position: position).to_h
  end
end

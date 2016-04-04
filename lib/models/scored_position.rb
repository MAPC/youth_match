# Not sure about this design.
class ScoredPosition < Position
  after_initialize :set_score

  private

  def set_score
    self.score = MatchScore.new(applicant: applicant, position: position).to_h
  end

end

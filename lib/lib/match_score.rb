class MatchScore < Score

  def score
    (travel_score + interest_score).to_i
  end

  def to_h
    { total: score,
      travel_score: travel_score,
      interest_score: interest_score }
  end

  private

  def travel_score
    @_travel_score ||= TravelScore.new(
      applicant: @applicant, position: @position
    ).score
  end

  def interest_score
    @_interest_score ||= InterestScore.new(
      applicant: @applicant, position: @position
    ).score
  end

end

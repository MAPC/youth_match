class MatchScore < Score

  def score
    (travel_score + interest_score).to_i
  end

  def travel_score
    TravelScore.new(applicant: @applicant, position: @position).score
  end

  def interest_score
    InterestScore.new(applicant: @applicant, position: @position).score
  end

end

require_relative './score'

class InterestScore < Score

  def score
    magnitude * matches
  end

  private

  def magnitude
    @applicant.prefers_interest? ? 5 : 3
  end

  def matches
    @applicant.interests.include?(@position.category) ? 1 : -1
  end

end

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
    intersection = @applicant.interests & @position.categories
    intersection.any? ? 1 : -1
  end

end

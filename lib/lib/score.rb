class Score

  def initialize(applicant: , position: )
    @applicant = applicant
    @position = position
  end

  def score
    raise NotImplementedError
  end

end

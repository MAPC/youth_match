require 'test_helper'

class MatchScoreTest < Minitest::Test

  def applicant
    @_applicant ||= Minitest::Mock.new
  end

  def position
    @_position ||= Minitest::Mock.new
  end

  def score
    @_score ||= MatchScore.new(applicant: applicant, position: position)
  end

end

require 'test_helper'

class InterestScoreTest < Minitest::Test

  def applicant
    @_applicant ||= Minitest::Mock.new
    @_applicant.expect(:interests, %w( a b c ))
  end

  def position
    @_position ||= Minitest::Mock.new
  end

  def score
    @_score ||= InterestScore.new(applicant: applicant, position: position)
  end

  def test_match_care
    applicant.expect(:prefers_interest?, true)
    position.expect(:categories, ['a'])
    assert_equal 5, score.score
  end

  def test_no_match_care
    applicant.expect(:prefers_interest?, true)
    position.expect(:categories, ['no-match'])
    assert_equal -5, score.score
  end

  def test_match_no_care
    applicant.expect(:prefers_interest?, false)
    position.expect(:categories, ['a'])
    assert_equal 3, score.score
  end

  def test_no_match_no_care
    applicant.expect(:prefers_interest?, false)
    position.expect(:categories, ['no-match'])
    assert_equal -3, score.score
  end

end

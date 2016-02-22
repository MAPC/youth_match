require 'test_helper'

class TravelScoreTest < Minitest::Test

  def teardown
    assert applicant.verify
    assert position.verify
  end

  def applicant
    @_applicant ||= Minitest::Mock.new
  end

  def position
    @_position ||= Minitest::Mock.new
  end

  def score
    @_score ||= TravelScore.new(applicant: applicant, position: position)
  end

  def test_score
    assert score.score
  end

  def test_travel_score
    applicant.expect(:travel_time_to, 10.minutes)
    applicant.expect(:prefers_nearby?, :false)
    assert_in_delta score.score, 3, 1

    applicant.expect(:prefers_nearby?, :true)
    assert_in_delta score.score, 0, 1
  end

=begin

SCORE REFERENCE POINTS

    Don't care      Care

 5  Job is in same grid cell

 3  10 minutes       5 minutes

 0  20 minutes      10 minutes

-3  30 minutes      20 minutes

-5  > 40 minutes

=end

end

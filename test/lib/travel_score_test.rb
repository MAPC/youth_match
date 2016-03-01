require 'test_helper'

class TravelScoreTest < Minitest::Test

  def applicant
    @_applicant ||= Minitest::Mock.new
  end

  def position
    @_position ||= Minitest::Mock.new
  end

  def score
    @_score ||= TravelScore.new(applicant: applicant, position: position)
  end

  def test_travel_score_when_time_negative
    applicant.expect :prefers_nearby?, false
    applicant.expect :mode, 1
    applicant.expect :grid_id, 1
    position.expect  :grid_id, 1
    TravelTime.stub :find_by, TravelTime.new(time: -1.seconds) do
      score = TravelScore.new(applicant: applicant, position: position)
      assert_raises(StandardError) { score.score }
    end
  end

  def test_travel_score_when_doesnt_care
    dont_care_scores.each do |hash|
      applicant.expect :prefers_nearby?, false
      applicant.expect :mode, 1
      applicant.expect :grid_id, 1
      position.expect  :grid_id, 1

      TravelTime.stub :find_by, TravelTime.new(time: hash[:time].minutes) do
        expected = hash[:score]
        actual = TravelScore.new(applicant: applicant, position: position)
        assert_in_delta expected, actual.score, 0.5
      end
      assert applicant.verify
    end

  end

  def test_travel_score_when_cares
    care_scores.each do |hash|
      applicant.expect :prefers_nearby?, true
      applicant.expect :mode, 1
      applicant.expect :grid_id, 1
      position.expect  :grid_id, 1

      TravelTime.stub :find_by, TravelTime.new(time: hash[:time].minutes) do
        expected = hash[:score]
        actual = TravelScore.new(applicant: applicant, position: position)
        assert_in_delta expected, actual.score, hash[:delta]
      end
      assert applicant.verify
    end
  end

  private

    def care_scores
      [{score:  3, time: 5,  delta: 0.75},
       {score:  0, time: 10, delta: 0.5},
       {score: -3, time: 20, delta: 0.5},
       {score: -5, time: 30, delta: 0.5},
       {score: -5, time: 40, delta: 0.5},
       {score: -5, time: 99, delta: 0.5}]
    end

    def dont_care_scores
      [{score:  3, time: 10},
       {score:  0, time: 20},
       {score: -3, time: 30},
       {score: -5, time: 40},
       {score: -5, time: 45},
       {score: -5, time: 99}]
    end

end

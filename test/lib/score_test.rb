require 'test_helper'

class ScoreTest < Minitest::Test

  def score
    @_score ||= Score.new(applicant: nil, position: nil)
  end

  def test_score_raises
    assert_raises(NotImplementedError) { score.score }
  end

end

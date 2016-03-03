require 'test_helper'

class MatchJobTest < Minitest::Test

  def setup
    @time = Time.now.freeze
  end

  def teardown
    Run.where('created_at <= ?', @time).destroy_all
  end

  def job
    @_job ||= MatchJob.new
  end

  def test_perform_creates_a_run
    before = Run.count
    job.perform!
    after = Run.count
    assert_equal 1, (after - before)
  end

end

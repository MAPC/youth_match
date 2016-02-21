require 'test_helper'

class RunTest < Minitest::Test

  def setup
    @run = Run.create!
  end

  def teardown
    @run.destroy!
  end

  def test_valid
    assert @run.valid?
  end

  def test_default_status
    assert_equal 'fresh', Run.new.status
  end

  def test_statuses
    @run.running!
    assert_equal 'running',   @run.status
    @run.failed!
    assert_equal 'failed',    @run.status
    @run.succeeded!
    assert_equal 'succeeded', @run.status
  end

  def test_run_performs_match_job
    skip 'Does performing the job get done by a collaborator?'
  end

  def test_generates_stats_after_run
    skip 'Could be another object that does this'
  end

end

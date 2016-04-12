require 'test_helper'

class RunTest < Minitest::Test

  def setup
    @run = Run.create!(limit: 10, seed: 1000)
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

  def test_limit
    assert_respond_to @run, :limit
    assert_equal 10, @run.limit
  end

  def test_given_no_seed
    new_run = Run.new(seed: nil)
    assert new_run.seed
    assert new_run.seed >= 1000
    assert new_run.seed <= 9999
  end

  def test_given_a_seed
    refute Run.new(seed: 100).valid?
    new_run = Run.new(seed: 1234)
    assert new_run.valid?
    assert_equal 1234, new_run.seed
  end

  def test_seed
    assert_respond_to @run, :seed
    assert_equal 1000, @run.seed
  end

  def test_sql_seed
    assert_respond_to @run, :sql_seed
    assert_equal 0.1000, @run.sql_seed
  end

  def test_run_config
    expected_config = {
      'score_multipliers' => { 'interest' => 1, 'travel' => 1 },
      'compressor' => { 'threshhold' => 40, 'ratio' => 2, 'direction' => 'upward' }
    }
    assert_equal expected_config, Run.new.config
    assert_equal 40, Run.new.config[:compressor][:threshhold]
    assert_equal 40, @run.config[:compressor][:threshhold]
  end

end

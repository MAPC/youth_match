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

  def test_seed
    assert_respond_to @run, :seed
    assert_equal 1000, @run.seed
  end

  def test_sql_seed
    assert_respond_to @run, :sql_seed
    assert_equal 0.1000, @run.sql_seed
  end

end

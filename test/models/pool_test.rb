require 'test_helper'

class PoolTest < Minitest::Test

  def pool
    @_pool ||= Pool.new(applicant: applicant, run: lottery_run)
  end

  def applicant
    @_applicant ||= Applicant.new
  end

  def lottery_run
    @_run ||= Run.new
  end

  def test_pool
    assert pool
  end

  def test_positions
    assert_respond_to pool, :positions
  end

  def test_allocates_positions
    assert_empty pool.positions
    pool.save!
    refute_empty pool.reload.positions
  ensure
    pool.destroy
  end

  def test_sets_position_count
    refute pool.position_count
    pool.save!
    assert_equal 0, pool.reload.position_count
  ensure
    pool.destroy
  end

  def test_sets_base_proportion
    refute pool.base_proportion
    pool.save!
    assert_equal 0, pool.reload.base_proportion
  ensure
    pool.destroy
  end

end

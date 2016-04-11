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
    assert_respond_to pool, :pooled_positions
  end

  def test_allocates_positions
    assert_empty pool.positions
    position = Position.create
    Position.stub :base_pool_for, [position] do
      TravelTime.stub :find_by, OpenStruct.new(time: 10.minutes) do
        pool.save!
      end
    end
    refute_empty pool.reload.positions
  ensure
    pool.destroy
  end

  def test_sets_position_count
    refute pool.position_count
    position = Position.create
    Position.stub :base_pool_for, [position] do
      TravelTime.stub :find_by, OpenStruct.new(time: 10.minutes) do
        pool.save!
      end
    end
    assert_equal 1, pool.reload.position_count
  ensure
    position.destroy!
    pool.destroy!
  end

  def test_best_fit
    skip 'ensure jobs are removed from pool if not available'
  end

end

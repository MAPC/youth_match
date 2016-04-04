require 'test_helper'

class PooledPositionTest < Minitest::Test

  def setup
    @applicant = Applicant.create!
    @position = Position.create!
    @run = Run.create!
    @pool = Pool.create!(applicant: @applicant, run: @run)
    @pooled_position = PooledPosition.new(pool: @pool, position: @position)
  end

  def teardown
    @applicant.destroy!
    @position.destroy!
    @run.destroy!
    @pool.destroy!
    @pooled_position.destroy!
  end

  def test_score
    TravelTime.stub :find_by, OpenStruct.new(time: 10.minutes) do
      @pooled_position.save!
    end
    assert @pooled_position.reload.score
  ensure
    @pooled_position.destroy!
  end

end

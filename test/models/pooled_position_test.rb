require 'test_helper'

class PooledPositionTest < Minitest::Test

  def setup
    placement = mock_placement
    @position = Position.create!
    @pool = Pool.create!(placement: placement)
    @pooled_position = PooledPosition.new(pool: @pool, position: @position)
  end

  def teardown
    @position.destroy!
    @pool.destroy!
    @pooled_position.destroy!
  end

  def test_valid
    assert @pooled_position.valid?, @pooled_position.errors.full_messages
  end

  def test_score
    TravelTime.stub :find_by, OpenStruct.new(time: 10.minutes) do
      @pooled_position.save!
    end
    assert @pooled_position.reload.score
  ensure
    @pooled_position.destroy!
  end

  private

  def mock_placement
    Placement.new(
      applicant: Applicant.new,
      position: Position.new,
      run: Run.new)
  end

end

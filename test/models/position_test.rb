require 'test_helper'

class PositionTest < Minitest::Test

  def setup
    @position = Position.first
    @run = Run.create!
  end

  def position
    @_position ||= @position
  end

  def test_valid
    assert position.valid?
  end

  def test_uuid
    assert_respond_to position, :uuid
    assert @position.reload.uuid
  end

  def test_category
    assert_respond_to position, :category
  end

  def test_grid_id
    assert_respond_to position, :grid_id
  end

  def test_travel_times
    assert_respond_to position, :travel_times
  end

  def test_within
    assert_send [Position, :within, of: Applicant.first]
  end

  def test_available
    assert_send [Position, :available, @run]
  end

end

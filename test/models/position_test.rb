require 'test_helper'

class PositionTest < Minitest::Test

  def setup
    @position = position.dup
    @position.save!
    @run = Run.create!
    @applicant = Applicant.create!(grid_id: 1)
  end

  def position
    @_position ||= Position.new(grid_id: 1)
  end

  def teardown
    @position.destroy!
    @applicant.destroy!
    @run.destroy!
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
    skip
  end

  def test_within?
    skip
  end

  def test_available
    skip
  end

end

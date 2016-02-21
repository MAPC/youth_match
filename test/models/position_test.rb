require 'test_helper'

class PositionTest < Minitest::Test

  def setup
    @position = position.dup
    @position.save!
  end

  def teardown
    @position.destroy
  end

  def position
    @_position ||= Position.new
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
    skip 'Once we decide on a strategy; see model file'
    assert_respond_to position, :grid_id
  end

end

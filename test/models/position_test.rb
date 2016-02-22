require 'test_helper'

class PositionTest < Minitest::Test

  def setup
    @position = position.dup
    @position.save!
    @run = Run.create!
    @applicant = Applicant.create!
  end

  def teardown
    @position.destroy!
    @applicant.destroy!
    @run.destroy!
    @placement.destroy! if @placement
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

  def test_scope_available
    refute_empty Position.available(@run)
    @placement = @run.placements.create!(
      applicant: @applicant,
      position: @position
    )
    assert_empty Position.available(@run)
  end

end

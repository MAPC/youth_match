require 'test_helper'

class PlacementTest < Minitest::Test

  def setup
    @run = Run.create!
    @applicant = Applicant.create!(grid_id: 1)
    @position = Position.create!(grid_id: 1)

    @placement = Placement.create!(
      run:       @run,
      applicant: @applicant,
      position:  @position
    )
  end

  def teardown
    @run.destroy!
    @applicant.destroy!
    @position.destroy!
    @placement.destroy!
  end

  def placement
    @placement
  end

  def test_valid
    placement.valid?
  end

  def test_requires_run
    placement.run = nil
    refute placement.valid?
  end

  def test_requires_applicant
    placement.applicant = nil
    refute placement.valid?
  end

  def test_does_not_require_position
    placement.position = nil
    assert placement.valid?
  end

  def test_requires_run_index
    placement.index = nil
    refute placement.valid?
  end

  def test_percentile
    skip "for the moment, but we'll want this"
  end

  def test_uuid
    assert placement.reload.uuid
  end

end

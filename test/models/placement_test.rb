require 'test_helper'

class PlacementTest < Minitest::Test

  def setup
    @run = Run.create!
    @applicant = Applicant.first
    @position = Position.first

    @placement = Placement.create!(
      run_id:       @run.id,
      applicant_id: @applicant.id,
      position_id:  @position.id
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

  def test_requires_position
    placement.position = nil
    refute placement.valid?
  end

  def test_uuid
    assert @placement.reload.uuid
  end

end

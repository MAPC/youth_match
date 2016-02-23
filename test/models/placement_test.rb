require 'test_helper'

class PlacementTest < Minitest::Test

  def setup
    @run = Run.create!
    @applicant = Applicant.create!
    @position = Position.create!

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

  def test_expiration
    assert_respond_to placement, :expiration
  end

  def test_expired
    assert_respond_to placement, :expired
    assert_respond_to placement, :expired?
    placement.expiration = nil
    assert placement.expired?
    placement.expiration = Time.at(2000)
    assert placement.expired?
    placement.expiration = 1.day.from_now
    refute placement.expired?
  end

  def test_status
    assert_equal 'potential', Placement.new.status
  end

  def test_accept_decline
    placement.decline
    assert_equal 'declined', placement.status
    placement.accept
    assert_equal 'accepted', placement.status
    placement.invalidate
    assert_equal 'invalid', placement.status
  end

  def test_predicates
    assert_respond_to placement, :accepted?
    assert_respond_to placement, :declined?
    assert_respond_to placement, :potential?
    assert_respond_to placement, :invalid?
  end

end

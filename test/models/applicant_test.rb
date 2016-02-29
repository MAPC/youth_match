require 'test_helper'

class ApplicantTest < Minitest::Test

  def setup
    @applicant = Applicant.first
  end

  def applicant
    @_applicant ||= @applicant
  end

  def test_valid
    assert applicant.valid?
  end

  def test_uuid
    assert @applicant.reload.uuid
  end

  def test_interests
    assert_instance_of Array, applicant.interests
  end

  def test_booleans
    assert_respond_to applicant, :prefers_nearby
    assert_respond_to applicant, :prefers_interest
    assert_respond_to applicant, :has_transit_pass
    # assert applicant.prefers_nearby?
    # refute applicant.prefers_interest?
    # refute applicant.has_transit_pass?
  end

  def test_grid_id
    assert_respond_to applicant, :grid_id
  end

  def test_travel_times
    assert_respond_to applicant, :travel_times
  end

  def test_mode
    applicant.has_transit_pass = false
    assert_equal :walking, applicant.mode

    applicant.has_transit_pass = true
    assert_equal :transit, applicant.mode
  end

end

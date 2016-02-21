require 'test_helper'

class ApplicantTest < Minitest::Test

  def applicant
    @_applicant ||= Applicant.new
  end

  def test_valid
    assert applicant.valid?
  end

  def test_uuid
    applicant.save!
    assert applicant.reload.uuid
  end

  def test_interests
    assert_instance_of Array, applicant.interests
  end

  def test_booleans
    assert_respond_to applicant, :prefers_nearby
    assert_respond_to applicant, :prefers_interest
    assert_respond_to applicant, :has_transit_pass
    assert applicant.prefers_nearby?
    refute applicant.prefers_interest?
    refute applicant.has_transit_pass?
  end

end

require 'test_helper'

class RelayTest < Minitest::Test

  include Rack::Test::Methods
  include Stub::Integration

  def app
    Apps::Relay
  end

  def setup
    @run = Run.create!
    Position.where(uuid: "1c48f911-28ac-4e3b-86df-ace38e8092bd").each &:destroy
    Applicant.where(uuid: "c4e12e70-52a5-4014-9990-7238627f37d7").each &:destroy

    @position  = Position.create!(id: 7777,  uuid: "1c48f911-28ac-4e3b-86df-ace38e8092bd")
    @applicant = Applicant.create!(id: 7777, uuid: "c4e12e70-52a5-4014-9990-7238627f37d7")
    @placement = @run.placements.create!(
      uuid: "f95bfae2-cfb3-4185-aeef-249792502e4d",
      applicant_id: @applicant.id,
      position_id: @position.id,
      run: @run, index: 1,
      workflow_id: 19288,
      market: :automatic
    )
    @placement.reload
  end

  def teardown
    @placement.destroy!
    @applicant.destroy!
    @position.destroy!
    @run.destroy!
  end

  def test_real
    assert app
  end

  def test_main_page
    get '/'
    assert last_response.ok?
    assert last_response.body.include? 'Hello'
  end

  def test_root_redirects
    skip 'for now'
  end

  def test_accepted_ok
    stub_get_workflow
    stub_accept_workflow
    accept
    assert_redirect_to('lottery-accepted')
    assert_equal 'accepted', @placement.reload.status
  end

  def test_declined_ok
    stub_get_workflow
    stub_decline_workflow
    decline
    assert_redirect_to('lottery-declined')
    assert_equal 'declined', @placement.reload.status
  end

  def test_accepted_one_character_deleted
    get "/placements/#{@placement.uuid}/accept",
      applicant_uuid: @placement.applicant.uuid,
      position_uuid:  @placement.position.uuid[0..34] # Truncate by 1
    assert_redirect_to('error')
  end

  def test_accepted_different_job
    position = Position.create!
    get "/placements/#{@placement.uuid}/accept",
      applicant_uuid: @placement.applicant.uuid,
      position_uuid:  position.uuid
    assert_redirect_to('error')
  ensure
    position.destroy!
  end

  def test_accepted_different_person
    applicant = Applicant.create!
    get "/placements/#{@placement.uuid}/accept",
      applicant_uuid: applicant.uuid,
      position_uuid:  @placement.position.uuid
    assert_redirect_to('error')
  ensure
    applicant.destroy!
  end

  def test_accepted_already_accepted
    stub_already_accepted
    @placement.update_attribute(:status, :accepted)
    accept
    assert_redirect_to('lottery-previous-accept')
  end

  def test_declined_already_accepted
    stub_already_accepted
    @placement.update_attribute(:status, :accepted)
    decline
    assert_redirect_to('lottery-previous-accept')
  end

  def test_declined_already_declined
    stub_already_declined
    @placement.update_attribute(:status, :declined)
    decline
    assert_redirect_to('lottery-offer-rematch')
  end

  def test_accepted_already_declined
    stub_already_declined
    @placement.update_attribute(:status, :declined)
    accept
    assert_redirect_to('lottery-offer-rematch')
  end

  def test_expired_locally
    @placement.update_attributes(expires_at: 1.day.ago)
    accept
    assert_redirect_to('expire')
    decline
    assert_redirect_to('expire')
  end

  def test_opt_out
    stub_get_workflow
    stub_decline_workflow
    opt_out
    assert_redirect_to('opt-out')
    assert_equal 'declined', @placement.reload.status
    assert_equal 'opted_out', @placement.applicant.status
  end

  def test_already_hired
    skip 'check ICIMS API during response, check to make sure unhired'
    # And mark person as hired.
  end

  def test_accepted_person_not_in_placements
    skip 'maybe irrelevant'
  end

  def test_accepted_icims_error
    skip 'retry 3 times, 1s wait, Airbrake because ICIMS may be down'
  end

  # If we move accept/decline to :action, test against wrong actions
  private

  def accept
    get "/placements/#{@placement.uuid}/accept",
      applicant_uuid: @placement.applicant.uuid,
      position_uuid:  @placement.position.uuid
  end

  def decline
    get "/placements/#{@placement.uuid}/decline",
      applicant_uuid: @placement.applicant.uuid,
      position_uuid:  @placement.position.uuid
  end

  def opt_out
    get "/placements/#{@placement.uuid}/opt-out",
      applicant_uuid: @placement.applicant.uuid,
      position_uuid:  @placement.position.uuid
  end

  def assert_redirect_to(place)
    assert last_response.redirect?, last_response.inspect
    follow_redirect!
    assert_includes last_request.url, place
  end

end

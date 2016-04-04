require 'test_helper'

class RelayTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Apps::Relay
  end

  def setup
    @run = Run.create!
    @position  = Position.create!(grid_id: 1)
    @applicant = Applicant.create!(grid_id: 1)
    @placement = Placement.create!(
      applicant: @applicant, position: @position, run: @run, index: 1
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
    get "/placements/#{@placement.uuid}/accept",
      applicant_id: @placement.applicant.uuid,
      position_id: @placement.position.uuid
    assert last_response.redirect?, last_response.status
    follow_redirect!
    assert_includes last_request.url, 'lottery-accepted'
    assert_equal 'accepted', @placement.reload.status
  end

  def test_declined_ok
    get "/placements/#{@placement.uuid}/decline",
      applicant_id: @placement.applicant.uuid,
      position_id: @placement.position.uuid
    assert last_response.redirect?, last_response.status
    follow_redirect!
    assert_includes last_request.url, 'lottery-declined'
    assert_equal 'declined', @placement.reload.status
  end

  def test_accepted_one_character_deleted
    skip
  end

  def test_accepted_different_job
    skip
  end

  def test_accepted_different_person
    skip
  end

  def test_accepted_person_not_in_placements
    skip
  end

  def test_accepted_icims_error
    skip 'retry 3 times, 1s wait, Airbrake because ICIMS may be down'
  end

  def test_accepted_already_accepted
    skip 'to error page'
    # stub_already_accepted
    # Need to check that they're not already accepted or declined
    # because that means someone on the phone already took this action.
    # This case should go to the error page
  end

  def test_declined_already_declined
    skip 'to error page'
    # stub_already_declined
    # Same as above
  end

  def test_accepted_already_declined
    skip 'same as above'
  end

  def test_declined_already_accepted
    skip 'same as above'
  end

  def test_already_hired
    skip 'check ICIMS API during response, check to make sure unhired'
  end

  def test_expired
    skip 'to expiration page'
  end

  def test_opt_out
    skip 'to opt out page'
  end

  # If we move accept/decline to :action, test against wrong actions

end

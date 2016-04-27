require 'test_helper'

class RelayTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Apps::Relay
  end

  def setup
    @run = Run.create!
    @position  = Position.create!(uuid: "1c48f911-28ac-4e3b-86df-ace38e8092bd")
    @applicant = Applicant.create!(uuid: "c4e12e70-52a5-4014-9990-7238627f37d7")
    @placement = @run.placements.create!(
      uuid: "f95bfae2-cfb3-4185-aeef-249792502e4d",
      applicant: @applicant,
      position: @position,
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
    accept
    assert_redirect_to('error')
  end

  def test_declined_already_accepted
    stub_already_accepted
    decline
    assert_redirect_to('error')
  end

  def test_declined_already_declined
    stub_already_declined
    decline
    assert_redirect_to('error')
  end

  def test_accepted_already_declined
    stub_already_declined
    accept
    assert_redirect_to('error')
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

  def stub_retries_accepted
    skip 'fill in rest of stub'
    stub_request(:get, "www.example.com").
      to_timeout.then.
      to_timeout.then.
      to_return(
        status: 200,
        body: File.read('.'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_already_accepted
    stub_request(:get, "https://api.icims.com/customers/1234/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-accepted.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

  def stub_already_declined
    stub_request(:get, "https://api.icims.com/customers/1234/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-declined.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

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

  def stub_get_workflow
    stub_request(:get, "https://api.icims.com/customers/1234/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-19288-placed.json'),
        :headers => { 'Content-Type' => 'application/json' }
      )
  end

  def stub_accept_workflow
    stub_request(:patch, "https://api.icims.com/customers/1234/applicantworkflows/19288").
    with(:body => "{\"status\":{\"id\":\"C36951\"}}",
         :headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
    to_return(:status => 204, :body => "", :headers => {'Content-Type'=>'application/json'})
  end

  def stub_decline_workflow
    stub_request(:patch, "https://api.icims.com/customers/1234/applicantworkflows/19288").
    with(:body => "{\"status\":{\"id\":\"C38469\"}}",
         :headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
    to_return(:status => 204, :body => "", :headers => {'Content-Type'=>'application/json'})
  end

end

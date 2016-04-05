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
      applicant: @applicant, position: @position, run: @run, index: 1,
      workflow_id: 19288)
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
    assert_redirect_to_accepted
    assert_equal 'accepted', @placement.reload.status
  end

  def test_declined_ok
    stub_get_workflow
    stub_decline_workflow
    decline
    assert_redirect_to_declined
    assert_equal 'declined', @placement.reload.status
  end

  def test_accepted_one_character_deleted
    get "/placements/#{@placement.uuid}/accept",
      applicant_id: @placement.applicant.uuid,
      position_id:  @placement.position.uuid[0..34] # Truncate by 1
    assert_redirect_to_error_page
  end


  def test_accepted_different_job
    position = Position.create
    get "/placements/#{@placement.uuid}/accept",
      applicant_id: @placement.applicant.uuid,
      position_id:  position.uuid
    assert_redirect_to_error_page
  ensure
    position.destroy!
  end

  def test_accepted_different_person
    applicant = Applicant.create
    get "/placements/#{@placement.uuid}/accept",
      applicant_id: applicant.uuid,
      position_id:  @placement.position.uuid
    assert_redirect_to_error_page
  ensure
    applicant.destroy!
  end

  def test_accepted_already_accepted
    stub_already_accepted
    accept
    assert_redirect_to_error_page
  end

  def test_declined_already_accepted
    stub_already_accepted
    decline
    assert_redirect_to_error_page
  end

  def test_declined_already_declined
    stub_already_declined
    decline
    assert_redirect_to_error_page
  end

  def test_accepted_already_declined
    stub_already_declined
    accept
    assert_redirect_to_error_page
  end

  def test_expired_locally
    skip 'to expiration page'
  end

  def test_opt_out
    skip 'to opt out page'
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
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-accepted.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

  def stub_already_declined
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-declined.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

  def accept
    get "/placements/#{@placement.uuid}/accept",
      applicant_id: @placement.applicant.uuid,
      position_id:  @placement.position.uuid
  end

  def decline
    get "/placements/#{@placement.uuid}/decline",
      applicant_id: @placement.applicant.uuid,
      position_id:  @placement.position.uuid
  end

  def stub_get_workflow
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-19288-placed.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

  def stub_accept_workflow
    stub_request(:patch, "https://api.icims.com/customers/6405/applicantworkflows/19288").
    with(:body => "{\"status\":{\"id\":\"C36951\"}}",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(:status => 204, :body => "", :headers => {'Content-Type'=>'application/json'})
  end

  def stub_decline_workflow
    stub_request(:patch, "https://api.icims.com/customers/6405/applicantworkflows/19288").
    with(:body => "{\"status\":{\"id\":\"C14661\"}}",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(:status => 204, :body => "", :headers => {'Content-Type'=>'application/json'})
  end

  def assert_redirect_to_error_page
    assert last_response.redirect?, last_response.inspect
    follow_redirect!
    assert_includes last_request.url, 'error'
  end

  def assert_redirect_to_accepted
    assert last_response.redirect?, last_response.errors
    follow_redirect!
    assert_includes last_request.url, 'lottery-accepted'
  end

  def assert_redirect_to_declined
    assert last_response.redirect?, last_response.errors
    follow_redirect!
    assert_includes last_request.url, 'lottery-declined'
  end

end

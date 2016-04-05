require 'test_helper'

class PlacementTest < Minitest::Test

  def setup
    @run = Run.create!
    @applicant = Applicant.create!(grid_id: 1)
    @position = Position.create!(grid_id: 1)

    @placement = Placement.create!(
      run:       @run,
      applicant: @applicant,
      position:  @position,
      index: 1
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

  def test_opportunities
    assert_respond_to placement, :opportunities
  end

  def test_percentile
    skip "for the moment, but we'll want this"
  end

  def test_uuid
    assert placement.reload.uuid
  end

  def test_null_workflow
    refute placement.workflow_id
    assert placement.workflow
    assert placement.workflow.nil?
    refute placement.workflow.present?
  end

  def test_finalize
    stub_finalize(job_id: placement.position.id, person_id: placement.applicant.id)
    stub_workflow
    assert_equal Status.pending, placement.status
    placement.finalize!
    assert_equal 21282, placement.workflow_id
    assert_equal Status.placed, placement.status
    assert placement.workflow
  end

  def test_already_decided
    # Check placement first, update with workflow if false
    stub_workflow
    p = Placement.new(workflow_id: 21282)
    refute p.already_decided?
    p.status = Status.declined
    assert p.already_decided?
    p.status = Status.accepted
    assert p.already_decided?
  end

  def test_already_decided_in_icims
    stub_get_accepted
    p = Placement.new(workflow_id: 19288)
    assert p.already_decided?
  end

  def test_expired
    assert_respond_to placement, :expired?
    assert_respond_to placement, :expires_at
    refute placement.expired?
    placement.expires_at = 4.days.from_now
    refute placement.expired?
    placement.expires_at = 4.days.ago
    assert placement.expired?

    # You can't go back once it's expired, because the status is set.
    placement.expires_at = 4.days.from_now
    assert placement.expired?

    # You can if you manually set the status, though.
    placement.status = :placed
    refute placement.expired?
  end

  private

  def stub_finalize(job_id: 2305, person_id: 2587)
    stub_request(:post, "https://api.icims.com/customers/6405/applicantworkflows").
    with(:body => "{\"baseprofile\":#{job_id},\"associatedprofile\":#{person_id},\"status\":{\"id\":\"PLACED\"},\"source\":\"Other (Please Specify)\",\"sourcename\":\"org.mapc.youthjobs.lottery\"}",
       :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(
      status: 201,
      body: '',
      headers: JSON.parse(File.read('./test/fixtures/icims/create-workflow-headers.json'))
    )
  end

  def stub_workflow
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/21282").
      with(:headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => File.read('./test/fixtures/icims/workflow-19288.json'), :headers => {'Content-Type' => 'application/json'})
  end

  def stub_get_accepted
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-accepted.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

end

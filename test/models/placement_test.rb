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
      index: 1,
      market: :automatic
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

  def test_market
    placement.market = :automatic
    assert placement.valid?
    placement.market = :manual
    assert placement.valid?
    placement.market = :automaGic
    refute placement.valid?
  end

  def test_requires_run_index
    placement.index = nil
    refute placement.valid?
  end

  def test_opportunities
    assert_respond_to placement, :opportunities
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
    placement.sync!
    assert_equal 21282, placement.workflow_id
    assert placement.workflow
    assert_equal Status.synced, placement.status
    assert placement.expires_at
  end

  def test_expiration_date
    Time.stub :now, Time.parse("Mon Apr 4 2016 09:00 AM") do
      expected = Time.parse("Fri Apr 8 2016 5:00 PM")
      assert_equal expected, placement.expiration_date
    end
    Time.stub :now, Time.parse("Tue Apr 5 2016 00:00 AM") do
      expected = Time.parse("Fri Apr 15 2016 5:00 PM")
      assert_equal expected, placement.expiration_date
    end
    Time.stub :now, Time.parse("Fri Apr 8 2016 05:00 PM") do
      expected = Time.parse("Fri Apr 15 2016 5:00 PM")
      assert_equal expected, placement.expiration_date
    end
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
    refute placement.valid?
    placement.status = :expired # Checking if symbol, not string, makes a diff
    refute placement.valid?

    # You can if you manually set the status, though.
    placement.status = :placed
    assert placement.valid?
    refute placement.expired?
  end

  def test_expired_placement_opts_out_applicant
    placement.expires_at = 4.days.ago
    refute placement.applicant.opted_out?
    placement.expired?
    assert placement.applicant.opted_out?
  end

  private

  def stub_finalize(job_id: 2305, person_id: 2587)
    stub_request(:post, "https://api.icims.com/customers/6405/applicantworkflows").
    with(:body => "{\"baseprofile\":#{job_id},\"associatedprofile\":#{person_id},\"status\":{\"id\":\"C38356\"},\"source\":\"Other (Please Specify)\",\"sourcename\":\"org.mapc.youthjobs.lottery\"}",
       :headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
    to_return(
      status: 201,
      body: '',
      headers: JSON.parse(File.read('./test/fixtures/icims/create-workflow-headers.json'))
    )
  end

  def stub_workflow
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/21282").
      with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => File.read('./test/fixtures/icims/workflow-19288.json'), :headers => {'Content-Type' => 'application/json'})
  end

  def stub_get_accepted
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/19288").
      with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
      to_return(
        :status => 200,
        :body => File.read('./test/fixtures/icims/workflow-accepted.json'),
        :headers => {'Content-Type' => 'application/json'}
      )
  end

end

require 'test_helper'

class ICIMS::WorkflowTest < Minitest::Test

  def setup
    stub_workflow
  end

  def workflow
    @_workflow ||= ICIMS::Workflow.find(19288)
  end

  # .find and .where should be tested on ICIMS::Resource
  def test_find
    assert workflow
  end

  def test_where
    stub_search
    stub_workflow(id: 19287) # Gets the normal stub file, so don't test content
    workflows = ICIMS::Workflow.where(person: workflow.person_id)
    assert_includes workflows.map(&:id), workflow.id
  end

  def test_job
    stub_job
    assert workflow.job
  end

  def test_person
    stub_person
    assert_equal 1, workflow.person.id
  end

  def test_eligible
    stub_eligible
    100.times { |i| stub_workflow(id: i+1) }
    assert_equal 100, ICIMS::Workflow.eligible.count
    assert_equal 10, ICIMS::Workflow.eligible(limit: 10).count
  end

  def test_updatable
    stub_update(status: ICIMS::Status.placed)
    assert_respond_to workflow, :updatable?
    workflow.placed
    assert workflow.updatable?, "workflow status: #{workflow.status.inspect}"
  end

  def test_not_updatable
    workflow.status = "NOT UPDATABLE"
    refute workflow.accepted
    refute workflow.declined
  end

  def test_create_from_attributes
    stub_create
    expected = ICIMS::Workflow.new(id: 21282, job_id: 1, person_id: 2, status: ICIMS::Status.placed)
    actual = ICIMS::Workflow.create(job_id: 1, person_id: 2, status: ICIMS::Status.placed)
    assert_equal expected, actual
  end

  def test_delete_workflow
    skip 'cannot delete, can update'
    stub_delete
    assert_equal workflow.delete
  end

  def test_save_from_new
    stub_create
    new_workflow = ICIMS::Workflow.new(id: nil, job_id: 1, person_id: 2, status: 'PLACED')
    assert new_workflow.save
    assert_equal 21282, new_workflow.id
  end

  def test_update_from_attributes
    stub_update
    accepted = ICIMS::Status.accepted
    assert workflow.update(status: accepted)
    assert_equal accepted, workflow.status
    refute workflow.update(status: accepted)
  end

  def test_not_updatable_after_deciding
    stub_update(status: ICIMS::Status.placed)
    stub_update(status: ICIMS::Status.accepted)
    workflow.placed
    workflow.accepted
    refute workflow.updatable?
  end

  def test_accepted
    stub_update(status: ICIMS::Status.placed)
    stub_update(status: ICIMS::Status.accepted)
    workflow.placed
    assert workflow.accepted, workflow.inspect
    assert_equal ICIMS::Status.accepted, workflow.status
    refute workflow.accepted
  end

  def test_declined
    stub_update(status: ICIMS::Status.placed)
    stub_update(status: ICIMS::Status.declined)
    workflow.placed
    assert workflow.declined, workflow.inspect
    assert_equal ICIMS::Status.declined, workflow.status
    refute workflow.declined
  end

  def test_placed
    stub_update(status: ICIMS::Status.placed)
    assert workflow.placed
    assert_equal ICIMS::Status.placed, workflow.status
    refute workflow.placed
  end

  def test_null
    [:placeable?, :decided?, :updatable?].each do |method|
      assert_respond_to ICIMS::Workflow.null, method
    end
  end

  private

  def stub_workflow(id: 19288)
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/#{id}").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/workflow-19288.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_person
    stub_request(:get, "https://api.icims.com/customers/6405/people/1?fields=field29946,field23848,field36999,addresses").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/person-1.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_job
    stub_request(:get, "https://api.icims.com/customers/6405/jobs/1346?fields=joblocation,jobtitle,numberofpositions,positioncategory").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/job-1123.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_search
    stub_request(:post, "https://api.icims.com/customers/6405/search/applicantworkflows").
    with(:body => "[{\"name\":\"applicantworkflow.person.id\",\"value\":[\"1\"],\"operator\":\"=\"}]",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(status: 200, body: File.read('./test/fixtures/icims/person-1-workflows.json'), headers: {'Content-Type'=>'application/json'})
  end

  def stub_eligible
    stub_request(:post, "https://api.icims.com/customers/6405/search/applicantworkflows").
    with(:body => "{\"filters\":[{\"name\":\"applicantworkflow.customfield4006.text\",\"value\":[],\"operator\":\"=\"},{\"name\":\"applicantworkflow.customfield4007.text\",\"value\":[],\"operator\":\"=\"},{\"name\":\"applicantworkflow.customfield3300.text\",\"value\":[\"135\"],\"operator\":\"=\"},{\"name\":\"applicantworkflow.person.createddate\",\"value\":[\"2013-03-25 4:00 AM\"],\"operator\":\"\\u003c\"}],\"operator\":\"\\u0026\"}",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(
      status: 200,
      body: File.read('./test/fixtures/icims/eligible-workflows.json'),
      headers: {'Content-Type'=>'application/json'})
  end

  def stub_create
    stub_request(:post, "https://api.icims.com/customers/6405/applicantworkflows").
    with(:body => "{\"baseprofile\":1,\"associatedprofile\":2,\"status\":{\"id\":\"PLACED\"},\"source\":\"Other (Please Specify)\",\"sourcename\":\"org.mapc.youthjobs.lottery\"}",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(
      status: 201,
      body: '',
      headers: JSON.parse(File.read('./test/fixtures/icims/create-workflow-headers.json'))
    )
  end

  def stub_update(status: ICIMS::Status.accepted)
    stub_request(:patch, "https://api.icims.com/customers/6405/applicantworkflows/19288").
    with(:body => "{\"status\":{\"id\":\"#{status}\"}}",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(
      status: 204,
      body: '',
      headers: JSON.parse(File.read('./test/fixtures/icims/create-workflow-headers.json'))
    )
  end

end

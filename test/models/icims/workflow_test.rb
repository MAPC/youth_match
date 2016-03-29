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

  def test_create
    skip
  end

  def test_update
    skip
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
    stub_request(:get, "https://api.icims.com/customers/6405/jobs/1346").
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

end


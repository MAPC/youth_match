require 'test_helper'

class ICIMS::WorkflowTest < Minitest::Test

  include Stub::Unit

  def setup
    stub_workflow(id: 19288)
  end

  def workflow
    @_workflow ||= ICIMS::Workflow.find(19288)
  end

  # .find and .where should be tested on ICIMS::Resource
  def test_find
    assert workflow
  end

  def test_where
    stub_workflows(id: 1) # search
    stub_workflow(id: 19287) # Gets the normal stub file, so don't test content
    workflows = ICIMS::Workflow.where(person: workflow.person_id)
    assert_includes workflows.map(&:id), workflow.id
  end

  def test_job
    stub_job(id: 1346)
    stub_company
    assert workflow.job
  end

  def test_person
    stub_person
    assert_equal 1, workflow.person.id
  end

  def test_eligible
    stub_eligible_workflows
    100.times { |i| stub_workflow(id: i+1) }
    assert_equal 100, ICIMS::Workflow.eligible.count
    assert_equal 10, ICIMS::Workflow.eligible(limit: 10).count
  end

  def test_updatable
    stub_update_workflow(status: ICIMS::Status.placed)
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
    stub_create_workflow
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
    stub_create_workflow
    new_workflow = ICIMS::Workflow.new(id: nil, job_id: 1, person_id: 2, status: 'C38356')
    assert new_workflow.save
    assert_equal 21282, new_workflow.id
  end

  def test_update_from_attributes
    stub_update_workflow
    accepted = ICIMS::Status.accepted
    assert workflow.update(status: accepted)
    assert_equal accepted, workflow.status
    refute workflow.update(status: accepted)
  end

  def test_not_updatable_after_deciding
    stub_update_workflow(status: ICIMS::Status.placed)
    stub_update_workflow(status: ICIMS::Status.accepted)
    workflow.placed
    workflow.accepted
    refute workflow.updatable?
  end

  def test_expired
    stub_expired_workflow
    assert workflow.expired?
  end

  def test_not_updatable_after_expiring
    skip
  end

  def test_accepted
    stub_update_workflow(status: ICIMS::Status.placed)
    stub_update_workflow(status: ICIMS::Status.accepted)
    workflow.placed
    assert workflow.accepted, workflow.inspect
    assert_equal ICIMS::Status.accepted, workflow.status
    refute workflow.accepted
  end

  def test_declined
    stub_update_workflow(status: ICIMS::Status.placed)
    stub_update_workflow(status: ICIMS::Status.declined)
    workflow.placed
    assert workflow.declined, workflow.inspect
    assert_equal ICIMS::Status.declined, workflow.status
    refute workflow.declined
  end

  def test_placed
    stub_update_workflow(status: ICIMS::Status.placed)
    assert workflow.placed
    assert_equal ICIMS::Status.placed, workflow.status
    refute workflow.placed
  end

  def test_null
    [:placeable?, :decided?, :updatable?].each do |method|
      assert_respond_to ICIMS::Workflow.null, method
    end
  end

  def test_resource_retries
    stub_timeouts
    assert workflow
  end

  def test_no_status
    stub_workflow_no_status
    assert_equal nil, ICIMS::Workflow.find(1000).status
  end

end

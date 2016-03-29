require 'test_helper'

class ICIMS::PersonTest < Minitest::Test

  def setup
    stub_person(id: 1)
    stub_person(id: 2)
  end

  def new_person
    @_new_person = ICIMS::Person.new
  end

  def person
    @_person ||= ICIMS::Person.find(1)
  end

  def opposite_person
    @_opp ||= ICIMS::Person.find(2)
  end

  def test_address
    expected = "1483 Tremont Street, Boston MA 02120"
    assert_equal expected, person.address
  end

  def test_workflows
    stub_workflows
    stub_workflow(id: 19287)
    stub_workflow(id: 19288)
    refute_empty person.workflows
  end

  def test_prefers_nearby
    assert person.prefers_nearby?
    refute opposite_person.prefers_nearby?
  end

  def test_prefers_interest
    refute person.prefers_interest?
    assert opposite_person.prefers_interest?
  end

  def test_has_transit_pass
    assert person.transit_pass?
    refute opposite_person.transit_pass?
  end

  def test_interests
    refute_empty person.interests
  end

  def test_status
    skip 'not clear how to assign status'
    assert_equal :available, person.status
    assert_equal :hired, oppposite_person.status
  end

  private

  def stub_person(id: 1)
    stub_request(:get, "https://api.icims.com/customers/6405/people/#{id}?fields=field29946,field23848,field36999,addresses").
      to_return(status: 200,
        body: File.read("./test/fixtures/icims/person-#{id}.json"),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_workflows(id: 1)
    stub_request(:post, "https://api.icims.com/customers/6405/search/applicantworkflows").
    with(:body => "[{\"name\":\"applicantworkflow.person.id\",\"value\":[\"#{id}\"],\"operator\":\"=\"}]",
         :headers => {'Authorization'=>'Basic', 'Content-Type'=>'application/json'}).
    to_return(status: 200,
        body: File.read("./test/fixtures/icims/person-1-workflows.json"),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_workflow(id: 19288)
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/#{id}").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/workflow-19288.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

end

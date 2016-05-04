require 'test_helper'

class ICIMS::PersonTest < Minitest::Test

  include Stub::Unit

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
    refute person.has_transit_pass?
    assert opposite_person.has_transit_pass?
  end

  def test_interests
    refute_empty person.interests
    [
      "Child Care or Teacher's Assistant",
      "Manufacturing, Science, Technology, Engineering and/or Math",
    ].each do |interest|
      assert_includes person.interests, interest
    end
  end

  def test_status
    skip 'not clear how to assign status'
    assert_equal :available, person.status
    assert_equal :hired, oppposite_person.status
  end

end

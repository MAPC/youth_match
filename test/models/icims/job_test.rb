require 'test_helper'

class ICIMS::JobTest < Minitest::Test

  include Stub::Unit

  def setup
    stub_job
    stub_company
  end

  def new_job
    @_job = ICIMS::Job.new(id: 1123, company_id: 1800,
      title: 'Theater & Writing Group Mentor',
      positions: 5, category: "Education or Tutoring")
  end

  def job
    ICIMS::Job.find(1123)
  end

  def test_find
    assert_equal new_job, job
  end

  def test_company
    assert_equal "826 Boston, Inc.", job.company.name
  end

  def test_address
    assert_equal job.address.to_h, job.company.address.to_h
    assert_equal '3035 Washington St', job.street
    assert_equal 'Roxbury', job.city
    assert_equal 'MA', job.state
    assert_equal '02119-1227', job.zip
    assert_includes job.attributes, :addresses
  end

  def test_categories
    skip 'Removed from interface.'
    assert_equal ["Education", "Tutoring"], job.categories
  end

  def test_original_category
    assert_equal "Education or Tutoring", job.category
  end

  def test_positions
    assert_equal 5, job.positions
  end

  def test_eligible
    stub_eligible_jobs
    100.times { |i| stub_job(id: i+1) }
    assert_equal 100, ICIMS::Job.eligible.count
    assert_equal 90, ICIMS::Job.eligible(offset: 10).count
    assert_equal 10, ICIMS::Job.eligible(limit: 10).count
  end


end

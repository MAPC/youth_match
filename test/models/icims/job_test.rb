require 'test_helper'

class ICIMS::JobTest < Minitest::Test

  def setup
    stub_job
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
    stub_company
    assert_equal "826 Boston, Inc.", job.company.name
  end

  def test_address
    stub_company
    assert_equal job.address, job.company.address
  end

  def test_categories
    assert_equal ["Education", "Tutoring"], job.categories
  end

  def test_positions
    assert_equal 5, job.positions
  end

  def test_eligible
    stub_eligible
    100.times { |i| stub_job(id: i+1) }
    assert_equal 100, ICIMS::Job.eligible.count
    assert_equal 10, ICIMS::Job.eligible(limit: 10).count
  end

  private

  def stub_job(id: 1123)
    stub_request(:get, "https://api.icims.com/customers/6405/jobs/#{id}?fields=joblocation,jobtitle,numberofpositions,positioncategory").
      to_return(
        status: 200,
        body: File.read("./test/fixtures/icims/job-1123.json"),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_company
    stub_request(:get, "https://api.icims.com/customers/6405/companies/1800").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/company-1800.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_eligible
    stub_request(:post, "https://api.icims.com/customers/6405/search/jobs").
    with(:body => "{\"filters\":[{\"name\":\"job.numberofpositions\",\"value\":[\"1\"],\"operator\":\"\\u003e=\"},{\"name\":\"job.postedto\",\"value\":[\"Successlink\"],\"operator\":\"=\"}],\"operator\":\"\\u0026\"}").
    to_return(:status => 200,
      :body => File.read('./test/fixtures/icims/eligible-jobs.json'),
      :headers => { 'Content-Type'=>'application/json' })
  end

end

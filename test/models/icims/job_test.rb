require 'test_helper'

class ICIMS::JobTest < Minitest::Test

  def new_job
    @_job = ICIMS::Job.new(id: 1123, company_id: 1800,
      title: 'Theater & Writing Group Mentor')
  end

  def job
    stub_job
    ICIMS::Job.find(1123)
  end

  def test_find
    assert_equal new_job.attributes, job.attributes
  end

  def test_company
    stub_company
    assert_equal "826 Boston, Inc.", job.company.name
  end

  def test_address
    stub_company
    assert_equal job.address, job.company.address
  end

  def test_positions
    stub_positions
    assert_equal 5, job.positions
  end

  private

  def stub_job
    file = File.read('./test/fixtures/icims/job-1123.json')
    stub_request(:get, 'https://api.icims.com/customers/6405/jobs/1123').
      to_return(status: 200, body: file,
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_company
    stub_request(:get, "https://api.icims.com/customers/6405/companies/1800").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/company-1800.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

  def stub_positions
    stub_request(:get, "https://api.icims.com/customers/6405/jobs/1123?fields=numberofpositions").
      with(:headers => {'Authorization'=>'Basic'}).
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/job-1123-positions.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

end

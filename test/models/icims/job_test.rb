require 'test_helper'

class ICIMS::JobTest < Minitest::Test

  def job
    @_job = ICIMS::Job.new(id: 1123, company_id: 1800,
      title: 'Theater & Writing Group Mentor')
  end

  def test_find
    file = File.read('./test/fixtures/icims/job-1123.json')
    stub_request(:get, 'https://api.icims.com/customers/6405/jobs/1123').
      to_return(status: 200, body: file, headers: {'Content-Type' => 'application/json'})
    assert_equal job.attributes, ICIMS::Job.find(1123).attributes
  end

end

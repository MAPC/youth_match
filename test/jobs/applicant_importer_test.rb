require 'test_helper'

class ApplicantImporterTest < Minitest::Test

  def importer
    @_importer ||= ApplicantImporter.new
  end

  def test_defaults
    assert_equal nil, importer.limit
    assert_equal 0, importer.offset
  end

  def test_opts
    i = ApplicantImporter.new(limit: 10, offset: 100)
    assert_equal 10, i.limit
    assert_equal 100, i.offset
  end

  def test_perform
    Applicant.destroy_all
    assert_equal 0, Applicant.count
    stub_eligible
    100.times do |i|
      stub_workflow(id: i+1)
      stub_person(id: i+1)
    end
    assert_respond_to importer, :perform!
    before = Applicant.count
    assert importer.perform!
    after = Applicant.count
    assert after > before, "From #{before} applicants to #{after}."
  ensure
    Applicant.destroy_all
  end

  private

  def stub_eligible
    stub_request(:post, "https://api.icims.com/customers/6405/search/applicantworkflows").
    with(:body => "{\"filters\":[{\"name\":\"applicantworkflow.customfield4006.text\",\"value\":[],\"operator\":\"=\"},{\"name\":\"applicantworkflow.customfield4007.text\",\"value\":[],\"operator\":\"=\"},{\"name\":\"applicantworkflow.customfield3300.text\",\"value\":[\"135\"],\"operator\":\"=\"},{\"name\":\"applicantworkflow.person.createddate\",\"value\":[\"2013-03-25 4:00 AM\"],\"operator\":\"\\u003c\"}],\"operator\":\"\\u0026\"}",
         :headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
    to_return(
      :status => 200,
      :body => File.read('./test/fixtures/icims/eligible-workflows.json'),
      :headers => {'Content-Type'=>'application/json'})
  end

  def stub_workflow(id: 1)
    stub_request(:get, "https://api.icims.com/customers/6405/applicantworkflows/#{id}").
    with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
    to_return(
      :status => 200,
      :body => File.read('./test/fixtures/icims/workflow-19288.json'),
      :headers => {'Content-Type'=>'application/json'}
    )
  end

  def stub_person(id: 1)
    stub_request(:get, "https://api.icims.com/customers/6405/people/#{id}?fields=field29946,field23848,field36999,addresses").
    with(:headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json'}).
    to_return(:status => 200, :body => File.read('./test/fixtures/icims/person-1.json'), :headers => {'Content-Type'=>'application/json'})
  end

end

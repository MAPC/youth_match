require 'test_helper'

class ApplicantImporterTest < Minitest::Test

  include Stub::Unit

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
    skip 'used to destroy_all first'
    assert_equal 0, Applicant.count
    stub_eligible_workflows
    100.times do |i|
      stub_workflow(id: i+1)
      stub_person(id: i+1)
    end
    assert_respond_to importer, :perform!
    before = Applicant.count
    assert importer.perform!
    after = Applicant.count
    assert after > before, "From #{before} applicants to #{after}."
  end

end

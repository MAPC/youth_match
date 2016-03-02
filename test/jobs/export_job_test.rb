require 'test_helper'

class ExportJobTest < Minitest::Test

  def job
    @_job ||= ExportJob.new
  end

  def test_perform
    skip 'Output CSV of applicant & position IDs and UUIDs'
    # Maybe this sets the expiration date to 8.days.from_now
  end

end

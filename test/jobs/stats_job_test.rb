require 'test_helper'

class StatsJobTest < Minitest::Test

  def job
    @_job ||= StatsJob.new
  end

end

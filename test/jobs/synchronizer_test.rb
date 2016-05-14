require 'test_helper'

class SynchronizerTest < Minitest::Test

  def setup
    @app = Applicant.create!
    @run = Run.create!
    2.times {
      @run.placements.create!(
        status: :placed,
        applicant: @app,
        index: rand(1..1000)
      )
    }
  end

  def teardown
    @run.destroy!
    @app.destroy!
  end

  def test_limit
    sync = Synchronizer.new(run_id: @run.id, dry_run: true, limit: '1', offset: nil)
    assert_equal 1, sync.synchronizable_placements.count

    two = Synchronizer.new(run_id: @run.id, dry_run: true, limit: 2, offset: nil)
    assert_equal 2, two.synchronizable_placements.count
  end

end

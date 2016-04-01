require 'test_helper'

class PositionTest < Minitest::Test

  def setup
    @position = position.dup
    @position.save!
    @run = Run.create!
    @applicant = Applicant.create!(grid_id: 1)
  end

  def position
    @_position ||= Position.new(grid_id: 1)
  end

  def teardown
    @position.destroy!
    @applicant.destroy!
    @run.destroy!
  end

  def test_valid
    assert position.valid?
  end

  def test_uuid
    assert_respond_to position, :uuid
    assert @position.reload.uuid
  end

  def test_category
    assert_respond_to position, :category
  end

  def test_grid_id
    assert_respond_to position, :grid_id
  end

  def test_travel_times
    assert_respond_to position, :travel_times
  end

  def test_within
    @applicant.update_attribute(:grid_id, 1)
    @position.update_attribute(:grid_id, 2)
    @time = TravelTime.create!(input_id: 1, target_id: 2, travel_mode: :walking, time: 10.minutes)
    refute_empty within_10min_walk
    assert_includes within_10min_walk, @position
    assert_empty within_10min_transit
  ensure
    @time.destroy if time
  end

  def within_10min_walk
    Position.within(10.minutes, of: @applicant, via: :walking)
  end

  def within_10min_transit
    Position.within(10.minutes, of: @applicant, via: :transit)
  end

  def test_available
    before = Position.available(@run).count
    @p = @run.placements.create!(position: @position, applicant: @applicant, index: 1)
    after = Position.available(@run).count
    assert_equal 1, (before - after)
  ensure
    @p.destroy! if @p
  end

  def test_new_from_icims
    stub_job(id: 1123)
    expected = Position.new()
    actual = Position.new(ICIMS::Job.find(1123).attributes)
    assert_equal expected, actual
  end

  private

  def stub_job(id: 1123)
    stub_request(:get, "https://api.icims.com/customers/6405/jobs/#{id}?fields=joblocation,jobtitle,numberofpositions,positioncategory").
      to_return(
        status: 200,
        body: File.read("./test/fixtures/icims/job-1123.json"),
        headers: { 'Content-Type' => 'application/json' })
  end

end

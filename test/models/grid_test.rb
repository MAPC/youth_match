require 'test_helper'

class GridTest < Minitest::Test
  def setup
    @grid = Grid.first
  end

  def grid
    @_grid ||= @grid
  end

  def test_travel_times
    assert_respond_to grid, :travel_times
  end

  def test_intersecting_grid
    assert_send [Grid, :intersecting_grid, location: Applicant.first.location]
  end
end

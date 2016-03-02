require 'test_helper'

class GridTest < Minitest::Test

  def setup
    @grid = Grid.create!(geom: 'POLYGON((-1 1, 1 1, 1 -1, -1 -1, -1 1))')
  end

  def teardown
    @grid.destroy!
  end

  def applicant
    @_applicant ||= Applicant.new(location: 'POINT(0 0)')
  end

  def test_intersecting_grid
    actual = Grid.intersecting_grid(location: applicant.location)
    assert_equal @grid, actual
  end
end

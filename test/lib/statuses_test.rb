require 'test_helper'

class StatusesTest < Minitest::Test

  def test_placed
    assert_equal 'placed', Status.placed
  end

  def test_icims_placed
    assert_equal 'PLACED', ICIMS::Status.placed
  end

  def test_icims_accepted
    assert_equal 'C36951', ICIMS::Status.accepted
  end

  def test_icims_declined
    assert_equal 'C14661', ICIMS::Status.declined
  end

end

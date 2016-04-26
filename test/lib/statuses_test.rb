require 'test_helper'

class StatusesTest < Minitest::Test

  def test_placed
    assert_equal 'placed', Status.placed
    assert_equal 'synced', Status.synced
  end

  def test_icims_placed
    assert_equal 'C38356', ICIMS::Status.placed
  end

  def test_icims_accepted
    assert_equal 'C36951', ICIMS::Status.accepted
  end

  def test_icims_declined
    assert_equal 'C38469', ICIMS::Status.declined
  end

  def test_icims_from_code
    assert_equal 'accepted', ICIMS::Status.from_code('C36951')
    assert_equal 'declined', ICIMS::Status.from_code('C38469')
  end

end

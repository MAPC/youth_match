require 'test_helper'

class DYEERedirectTest < Minitest::Test

  def redirect
    DYEERedirect
  end

  def test_accept
    expected = ['http://youth.boston.gov/lottery-accepted', 307] # 308 w new rack
    assert_equal expected, redirect.to(:accept)
  end

  def test_decline
    expected = ['http://youth.boston.gov/lottery-declined', 307] # 308 w new rack
    assert_equal expected, redirect.to(:decline)
  end

  def test_error
    expected = ['http://youth.boston.gov/lottery-error', 307]
    assert_equal expected, redirect.to(:error)
  end

end

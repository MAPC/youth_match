require 'test_helper'

class ICIMS::CompanyTest < Minitest::Test

  include Stub::Unit

  def company
    stub_company
    ICIMS::Company.find(1800)
  end

  def test_find
    assert company
  end

  def test_address
    stub_company
    assert company.address
  end

end


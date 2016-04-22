require 'test_helper'

class AddressTest < Minitest::Test

  def address
    @_address ||= ICIMS::Address.new(valid_address_json)
  end

  def test_attributes
    %i( street city state zip ).each do |method|
      assert_respond_to address, method
    end
    assert_equal address.street, '3035 Washington St'
    assert_equal address.city,   'Roxbury'
    assert_equal address.state,  'MA'
    assert_equal address.zip,    '02119-1227'
    assert_equal address.zip_5,  '02119'
  end

  def test_no_object_given
    assert_raises { ICIMS::Address.new(nil) }
  end

  def test_to_s
    assert_equal '3035 Washington St, Roxbury MA 02119-1227', address.to_s
  end

  def test_to_a
    expected = ['3035 Washington St', 'Roxbury', 'MA', '02119-1227']
    assert_equal expected, address.to_a
  end

  def test_to_h
    expected = {
      street: '3035 Washington St',
      city: 'Roxbury',
      state: 'MA',
      zip: '02119-1227'
    }
    assert_equal expected, address.to_h
  end

  private

  def valid_address_json
    JSON.parse(File.read('./test/fixtures/icims/company-1800.json')).fetch('addresses')
  end
end

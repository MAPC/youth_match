require 'test_helper'

class ICIMS::CompanyTest < Minitest::Test

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

  private

  def stub_company
    stub_request(:get, "https://api.icims.com/customers/1234/companies/1800").
      to_return(status: 200,
        body: File.read('./test/fixtures/icims/company-1800.json'),
        headers: { 'Content-Type' => 'application/json' })
  end

end


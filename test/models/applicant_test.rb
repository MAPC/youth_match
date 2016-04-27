require 'test_helper'

class ApplicantTest < Minitest::Test

  def setup
    @applicant = applicant.dup
    @applicant.save!
  end

  def teardown
    @applicant.destroy!
  end

  def applicant
    @_applicant ||= Applicant.new(grid_id: 1)
  end

  def test_valid
    assert applicant.valid?
  end

  def test_uuid
    assert @applicant.reload.uuid
  end

  def test_interests
    assert_instance_of Array, applicant.interests
  end

  def test_address_components
    [:address, :state, :city, :street, :zip, :zip_5].each do |method|
      assert_respond_to applicant, method
    end
  end

  def test_status
    assert_respond_to applicant, :status
    assert_equal 'pending', applicant.status
  end

  def test_booleans
    assert_respond_to applicant, :prefers_nearby
    assert_respond_to applicant, :prefers_interest
    assert_respond_to applicant, :has_transit_pass
    # assert applicant.prefers_nearby?
    # refute applicant.prefers_interest?
    # refute applicant.has_transit_pass?
  end

  def test_grid_id
    assert_respond_to applicant, :grid_id
  end

  def test_travel_times
    assert_respond_to applicant, :travel_times
  end

  def test_mode
    @applicant.has_transit_pass = false
    assert_equal 'walking', @applicant.mode
    @applicant.save
    assert_equal 'walking', @applicant.mode

    @applicant.has_transit_pass = true
    assert_equal 'transit', @applicant.mode
    @applicant.update_attribute(:has_transit_pass, true)
    assert_equal 'transit', @applicant.mode
  end

  def test_mode_is_enumerized
    skip 'not critical'
  end

  def test_new_from_icims
    stub_person(id: 2)
    expected = Applicant.new(
      id: 2,
      interests: ["Child Care or Teacher's Assistant", "Community Organizing", "Construction or Building Trades"],
      prefers_nearby: false,
      has_transit_pass: true,
      addresses: [{"addresscity"=>"Boston", "entry"=>1001, "addresszip"=>"02111", "addressstate"=>{"id"=>"D41001024", "abbrev"=>"MA", "value"=>"Massachusetts"}, "addresscountry"=>{"id"=>"D41001", "abbrev"=>"US", "value"=>"United States"}, "addresstype"=>{"id"=>"D84002", "formattedvalue"=>"Home", "value"=>"Home"}, "addressstreet1"=>"60 Temple Place"}]
    )
    actual = Applicant.new_from_icims(ICIMS::Person.find(2))
    assert_equal expected.attributes, actual.attributes
  end

  private

  def stub_person(id: 1)
    stub_request(:get, "https://api.icims.com/customers/1234/people/#{id}?fields=field29946,field23848,field36999,addresses").
        to_return(status: 200,
          body: File.read("./test/fixtures/icims/person-#{id}.json"),
          headers: { 'Content-Type' => 'application/json' })
  end

end

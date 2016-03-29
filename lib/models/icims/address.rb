require_relative './resource'

class ICIMS::Address

  def initialize(addresses)
    @addresses = addresses
    @address = @addresses.first
  end

  def street
    street = @address['addressstreet1']
    street << ' ' + @address['addressstreet2'] if @address['addressstreet2']
    street
  end

  def city
    @address['addresscity']
  end

  def state
    @address['addressstate']['abbrev']
  end

  def zip
    @address['addresszip']
  end

  def to_s
    "#{street} #{city}, #{state} #{zip}"
  end

end

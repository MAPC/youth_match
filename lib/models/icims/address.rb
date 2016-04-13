require_relative './resource'

class ICIMS::Address

  def initialize(addresses)
    @addresses = Array(addresses)
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
    @address.
      fetch('addressstate', {}).
      fetch('abbrev', 'MA')
  end

  def zip
    @address['addresszip']
  end

  def to_s
    return "" if @addresses.empty?
    "#{street}, #{city} #{state} #{zip}"
  end

end

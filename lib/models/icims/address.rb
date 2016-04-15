require_relative './resource'

class ICIMS::Address

  attr_reader :street, :city, :state, :zip

  def initialize(addresses)
    @addresses = Array(addresses)
    @address = @addresses.first
    @street = street
    @city = city
    @state = state
    @zip = zip
  end

  def zip_5
    @zip.partition('-').first
  end

  def street
    str = @address.fetch('addressstreet1')
    if street2 = @address.fetch('addressstreet2', false)
      str << ' ' + street2
    end
    str
  end

  def city
    @address.fetch('addresscity')
  end

  def state
    @address.
      fetch('addressstate', {}).
      fetch('abbrev', 'MA')
  end

  def zip
    @address.fetch('addresszip')
  end

  def to_s
    return "" if @addresses.empty?
    "#{street}, #{city} #{state} #{zip}"
  end

  def to_a
    [@street, @city, @state, @zip]
  end

  def to_h
    Hash[[:street, :city, :state, :zip].zip(to_a)]
  end

end

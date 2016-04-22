require_relative './resource'

class ICIMS::Company < ICIMS::Resource

  attr_accessor :id, :name, :addresses

  def initialize(id: , name: , addresses: )
    @id   = id
    @name = name
    @addresses = addresses
  end

  def address
    @address ||= ICIMS::Address.new(@addresses)
  end

  def self.find(id)
    response = retry_get("/companies/#{id}", headers: headers)
    handle response do |r|
      self.new(id: id, name: r['name'], addresses: r.fetch('addresses'))
    end
  end
end

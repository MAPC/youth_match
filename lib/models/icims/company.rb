require_relative './resource'

class ICIMS::Company < ICIMS::Resource

  attr_accessor :id, :name, :addresses

  def initialize(id: , name: , addresses: )
    @id   = id
    @name = name
    @addresses = addresses
  end

  def address
    ICIMS::Address.new(@addresses).to_s
  end

  def self.find(id)
    response = get("/companies/#{id}", headers: headers)
    handle response do |r|
      self.new(id: id, name: r['name'], addresses: r['addresses'])
    end
  end
end

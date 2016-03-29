require_relative './resource'

class ICIMS::Job < ICIMS::Resource

  attr_accessor :id, :title, :address

  def initialize(id: , title: , company_id: )
    @id    = id
    @title = title
    @company_id = company_id
  end

  def company
    @company ||= ICIMS::Company.find(@company_id)
  end

  def address
    company.address
  end

  def positions
    response = self.class.get("/jobs/#{@id}?fields=numberofpositions", headers: self.class.headers)
    handle response do |r|
      r['numberofpositions']
    end
  end

  def self.find(id)
    response = get("/jobs/#{id}", headers: headers)
    handle response do |r|
      self.new(
        id: id,
        title: r['jobtitle'],
        company_id: r['joblocation']['companyid']
      )
    end
  end
end

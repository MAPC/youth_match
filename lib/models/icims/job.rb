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

  def self.eligible(limit: nil)
    local_headers = headers.merge({ 'Content-Type' => 'application/json' })
    response = post '/search/jobs',
      { body: eligible_filter.to_json, headers: local_headers }
    handle response do |r|
      limit_results(r, limit).map { |res| find res['id'] }
    end
  end

  def self.find(id)
    response = get("/jobs/#{id}", headers: headers)
    handle response do |r|
      self.new(id: id, title: r['jobtitle'],
        company_id: r['joblocation']['companyid'])
    end
  end

  private

  def self.eligible_filter
    {
      filters: [
        { name: "job.numberofpositions", value: ["1"], operator: ">=" },
        { name: "job.postedto", value: ["Successlink"], operator: "=" }
      ],
      operator: "&"
    }
  end
end

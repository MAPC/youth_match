require_relative './resource'

class ICIMS::Job < ICIMS::Resource

  attr_accessor :id, :title, :address, :category, :positions

  def initialize(attributes={})
    @id    = attributes[:id]
    @title = attributes[:title]
    @company_id = attributes[:company_id]
    @positions  = attributes[:positions]
    @category   = attributes[:category]
  end

  def company
    @company ||= ICIMS::Company.find(@company_id)
  end

  def address
    company.address
  end

  def self.eligible(limit: nil)
    response = post '/search/jobs',
      { body: eligible_filter.to_json, headers: headers }
    handle response do |r|
      limit_results(r, limit).map { |res| find res['id'] }
    end
  end

  def self.find(id)
    response = get("/jobs/#{id}?fields=#{field_names.join(',')}", headers: headers)
    handle response do |r|
      self.new(id: id, title: r['jobtitle'],
        company_id: r['joblocation']['companyid'],
        positions:  r['numberofpositions'],
        category:   r['positioncategory']['formattedvalue']
      )
    end
  end

  private

  def self.field_names
    %w( joblocation jobtitle numberofpositions positioncategory )
  end

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

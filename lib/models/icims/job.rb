require_relative './resource'

class ICIMS::Job < ICIMS::Resource

  attr_reader :id, :title, :address, :positions, :category, :categories

  def initialize(attributes={})
    @id    = attributes[:id]
    @title = attributes[:title]
    @company_id = attributes[:company_id]
    @positions  = attributes[:positions]
    @category   = attributes[:category]
    @categories ||= categories
  end

  def categories
    CategorySplitter.split(@category)
  end

  def company
    @company ||= ICIMS::Company.find(@company_id)
  end

  def address
    company.address
  end

  def self.eligible(limit: nil, offset: 0)
    response = retry_post '/search/jobs',
      { body: eligible_filter.to_json, headers: headers }
    results = handle(response) { |r| limit_results(r, limit, offset) }
    if block_given?
      results.each do |res|
        yield find(res['id'])
      end
    else
      results.map { |res| find res['id'] }
    end
  end

  def self.find(id)
    response = retry_get("/jobs/#{id}?fields=#{field_names.join(',')}", headers: headers)
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

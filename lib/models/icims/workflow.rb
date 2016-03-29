require_relative './resource'

class ICIMS::Workflow < ICIMS::Resource

  attr_reader :id, :job_id, :person_id, :status

  def initialize(id: , job_id: , person_id: , status: )
    @id = id
    @job_id = job_id
    @person_id = person_id
    @status = status
  end

  def job
    @job ||= ICIMS::Job.find(@job_id)
  end

  def person
    @person ||= ICIMS::Person.find(@person_id)
  end

  def create
    raise NotImplementedError, "find me in #{__FILE__}"
  end

  def self.find(id)
    response = get("/applicantworkflows/#{id}", headers: headers)
    handle response do |r|
      new(id: id, job_id: r['baseprofile']['id'], status: r['status']['value'],
        person_id: r['associatedprofile']['id'])
    end
  end

  def self.where(options={})
    local_headers = headers.merge({ 'Content-Type' => 'application/json' })
    response = post '/search/applicantworkflows',
      { body: build_filters(options).to_json, headers: local_headers }
    handle response do |r|
      Array(r['searchResults']).map { |res| find(res['id']) }
    end
  end

  def self.eligible(limit: nil)
    local_headers = headers.merge({ 'Content-Type' => 'application/json' })
    response = post '/search/applicantworkflows',
      { body: eligible_filter.to_json, headers: local_headers }
    handle response do |r|
      limit_results(r, limit).map { |res| find res['id'] }
    end
  end

  private

  def self.build_filters(options)
    filters = { filters: [], operator: '&' }
    filters[:filters] << person_filter(options) if options.include?(:person)
  end

  def self.person_filter(options)
    {
      name: 'applicantworkflow.person.id',
      value: [options[:person].to_s],
      operator: '='
    }
  end

  def self.eligible_filter
    {
      filters: [
        {name: "applicantworkflow.customfield4006.text", value: [], operator: "="},
        {name: "applicantworkflow.customfield4007.text", value: [], operator: "="},
        {name: "applicantworkflow.customfield3300.text", value: ["135"], operator: "="},
        {
          name: "applicantworkflow.person.createddate",
          value: ["2013-03-25 4:00 AM"], # 4 AM since the time is in UTC
          operator: "<"
        }
      ],
      operator: "&"
    }
  end
end

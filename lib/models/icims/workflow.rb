require_relative './resource'

class ICIMS::Workflow < ICIMS::Resource

  def initialize(id: , job_id: , person_id: , status: )
    @id = id
    @job_id = job_id
    @person_id = person_id
    @status = status
  end

  def self.find(id)
    response = get("/applicantworkflows/#{id}", headers: headers)
    handle response do |r|
      new(id: id, job_id: r['baseprofile']['id'], status: r['status']['value'],
        person_id: r['associatedprofile']['id'])
    end
  end

  def job
    @job ||= ICIMS::Job.find(@job_id)
  end

  def person
    @person ||= ICIMS::Person.find(@person_id)
  end

  def self.where(options={})
    filters = {filters: [], operator: '&'}
    filters[:filters] << person_filter(options) if options.include?(:person)
    local_headers = headers.merge({ 'Content-Type' => 'application/json' })
    response = post '/search/applicantworkflows',
      { body: filters.to_json, headers: local_headers }
    handle response do |r|
      r['searchResults'].map { |res| find(res['id']) }
    end
  end

  private

  def self.person_filter(options)
    {
      name: 'applicantworkflow.person.id',
      value: [options[:person].to_s],
      operator: '='
    }
  end
end

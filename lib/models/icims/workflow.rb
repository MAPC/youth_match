require_relative './resource'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'naught'

class ICIMS::Workflow < ICIMS::Resource

  attr_reader :id, :job_id, :person_id

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

  # Move to ICIMS::Resource
  def save
    response = self.class.create(self.attributes.merge({id: nil}), return_instance: false)
    @id = self.class.get_id_from(response)
    true
  end

  def self.create(attributes, return_instance: true)
    payload = {
      baseprofile: attributes[:job_id],
      associatedprofile: attributes[:person_id],
      status: { id: attributes[:status] },
      source: "Other (Please Specify)",
      sourcename: 'org.mapc.youthjobs.lottery'
    }.to_json
    response = retry_post '/applicantworkflows', { body: payload }
    if return_instance
      new(attributes.merge({ id: get_id_from(response) }))
    else
      response
    end
  end

  def update(status: nil, validate: true)
    return false if @status == status
    payload = { status: { id: status } }.to_json
    response = self.class.retry_patch "/applicantworkflows/#{@id}", { body: payload }
    handle response do |r|
      @status = status
      return true
    end
  end

  def status
    ICIMS::Status.from_code @status
  end

  def icims_status
    @status
  end

  def icims_status=(icims_status_code)
    @status = icims_status_code
  end

  def accepted
    return false unless updatable?
    update status: ICIMS::Status.accepted
  end

  def declined
    return false unless updatable?
    update status: ICIMS::Status.declined
  end

  def placed
    return false unless placeable?
    update status: ICIMS::Status.placed
  end

  def expired
    return false unless placeable?
    update status: ICIMS::Status.expired
  end

  def updatable?
    placed? && !expired?
  end

  def accepted?
    ICIMS::Status.acceptable.include? @status.to_s
  end

  def declined?
    ICIMS::Status.declinable.include? @status.to_s
  end

  def expired?
    ICIMS::Status.expirable.include? @status.to_s
  end

  def placed?
    @status.to_s == ICIMS::Status.placed
  end

  def placeable?
    !decided? || !expired?
  end

  def decided?
    [ICIMS::Status.accepted, ICIMS::Status.declined].include? @status.to_s
  end

  def self.find(id)
    response = retry_get("/applicantworkflows/#{id}")
    handle response do |r|
      job_id    = r.fetch('baseprofile', {}).fetch('id')
      person_id = r.fetch('associatedprofile', {}).fetch('id')
      status    = r.fetch('status', {}).fetch('id', nil)
      params = { id: id, job_id: job_id, status: status, person_id: person_id }
      new(params)
    end
  end

  def self.where(options={})
    response = retry_post '/search/applicantworkflows',
      { body: build_filters(options).to_json }
    handle response do |r|
      Array(r['searchResults']).map { |res| find(res['id']) }
    end
  end

  def self.eligible(limit: nil, offset: 0, &block)
    response = retry_post '/search/applicantworkflows',
      { body: eligible_filter.to_json }
    results = handle(response) { |r| limit_results(r, limit, offset) }
    if block_given?
      results.each do |res|
        yield find(res['id'])
      end
    else
      results.map { |res| find res['id'] }
    end
  end

  def self.null
    @@null ||= build_null_object.new
  end

  private

  def self.build_null_object
    Naught.build do |c|
      c.mimic(ICIMS::Workflow)
      c.black_hole
      c.predicates_return false
      def nil?
        true
      end
      def present?
        false
      end
    end
  end

  def self.get_id_from(response)
    response.headers['location'].to_s.rpartition('/').last.to_i
  end

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

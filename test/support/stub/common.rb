module Stub
  module Common

    def workflow_url(id=nil)
      url = "https://api.icims.com/customers/1234/applicantworkflows"
      url << "/#{id}" if id
      url
    end

    def search_workflows_url
      "https://api.icims.com/customers/1234/search/applicantworkflows"
    end

    def get_person_url(id)
      "https://api.icims.com/customers/1234/people/#{id}?fields=field29946,field23848,field36999,addresses"
    end

    def get_job_url(id)
      url = "https://api.icims.com/customers/1234/jobs/#{id}"
      url << "?fields=joblocation,jobtitle,numberofpositions,positioncategory"
      url
    end

    def company_url
      "https://api.icims.com/customers/1234/companies/1800"
    end

    def request_headers
      { 'Authorization' => 'Basic ', 'Content-Type' => 'application/json', 'User-Agent' => 'test' }
    end

    def response_headers
      { 'Content-Type' => 'application/json' }
    end

    def icims_fixture(name)
      File.read "./test/fixtures/icims/#{name}.json"
    end

    def ok_response_for(name)
      {
        status:  ok,
        body:    icims_fixture(name),
        headers: response_headers
      }
    end

    def created_response_for(name)
      {
        status:  created,
        body:    '',
        headers: JSON.parse(icims_fixture(name))
      }
    end

    def no_content_response
      {
        status:  no_content,
        body:    '',
        headers: response_headers
      }
    end

    def ok
      200
    end

    def created
      201
    end

    def no_content
      204
    end

    def status(status)
      { status: { id: status } }
    end


  end
end

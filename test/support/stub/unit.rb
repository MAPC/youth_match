module Stub
  module Unit

    include Stub::Common
    include Stub::Payloads

    def stub_eligible_workflows
      stub_request(:post, search_workflows_url).
        with(body: workflows_search.to_json, headers: request_headers).
        to_return(ok_response_for('eligible-workflows'))
    end

    def stub_workflow(id: 1)
      stub_request(:get, workflow_url(id)).
        with(headers: request_headers).
        to_return(ok_response_for('workflow-19288'))
    end

    def stub_person(id: 1)
      stub_request(:get, get_person_url(id)).
        with(headers: request_headers).
        to_return(ok_response_for("person-#{id}"))
    end

    def stub_finalize(job_id: 2305, person_id: 2587)
      stub_request(:post, workflow_url).
        with(
          body: create_workflow(job_id: job_id, person_id: person_id).to_json,
          headers: request_headers
        ).
        to_return(created_response_for('create-workflow-headers'))
    end

    def stub_get_accepted
      stub_request(:get, "https://api.icims.com/customers/1234/applicantworkflows/19288").
        with(headers: request_headers).
        to_return(ok_response_for('workflow-accepted'))
    end

    def stub_job(id: 1123)
      stub_request(:get, get_job_url(id)).
        with(headers: request_headers).
        to_return(ok_response_for('job-1123'))
    end

    def stub_company
      stub_request(:get, company_url).
        with(headers: request_headers).
        to_return(ok_response_for('company-1800'))
    end

    def stub_eligible_jobs
      stub_request(:post, "https://api.icims.com/customers/1234/search/jobs").
        with(body: jobs_search.to_json).
        to_return(ok_response_for('eligible-jobs'))
    end

    def stub_workflows(id: 1)
      stub_request(:post, search_workflows_url).
        with(
          body: "[{\"name\":\"applicantworkflow.person.id\",\"value\":[\"#{id}\"],\"operator\":\"=\"}]",
          headers: request_headers).
        to_return(ok_response_for('person-1-workflows'))
    end

    def stub_workflow_no_status(id: 1000)
      stub_request(:get, workflow_url(id)).to_return(ok_response_for('workflow-1000'))
    end

    def stub_create_workflow
      stub_request(:post, workflow_url).
        with(body: create_workflow(job_id: 1, person_id: 2), headers: request_headers).
        to_return(
          status: 201,
          body: '',
          headers: JSON.parse(icims_fixture('create-workflow-headers'))
        )
    end

    def stub_update_workflow(status: ICIMS::Status.accepted)
      stub_request(:patch, workflow_url(19288)).
        with(body: status(status), headers: request_headers).
        to_return(
          status: no_content,
          body: '',
          headers: JSON.parse(icims_fixture('create-workflow-headers'))
        )
    end

    def stub_timeouts
      timeout = Typhoeus::Response.new(code: 408, body: '')
      success = Typhoeus::Response.new(code: 200,
        body:    icims_fixture('workflow-19288'),
        headers: response_headers
      )
      Typhoeus.stub(workflow_url).and_return([timeout, timeout, success])
    end

    def stub_expired_workflow(id: 19288)
      stub_request(:get, workflow_url(id)).
        to_return(ok_response_for('workflow-expired'))
    end

  end
end

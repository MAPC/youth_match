module Stub
  module Integration

    include Stub::Common

    def stub_already_accepted
      stub_request(:get, workflow_url(19288)).
        with(headers: request_headers).
        to_return(ok_response_for('workflow-accepted'))
    end

    def stub_already_declined
      stub_request(:get, workflow_url(19288)).
        with(headers: request_headers).
        to_return(ok_response_for('workflow-declined'))
    end

    def stub_get_workflow
      stub_request(:get, workflow_url(19288)).
        with(headers: request_headers).
        to_return(ok_response_for('workflow-19288-placed'))
    end

    def stub_accept_workflow
      stub_request(:patch, workflow_url(19288)).
        with(body: status('C36951').to_json, headers: request_headers).
        to_return(no_content_response)
    end

    def stub_decline_workflow
      stub_request(:patch, workflow_url(19288)).
        with(body: status('C38469').to_json, headers: request_headers).
        to_return(no_content_response)
    end

    def stub_expire_workflow
      stub_request(:patch, "https://api.icims.com/customers/1234/applicantworkflows/19288").
        with(:body => "{\"status\":{\"id\":\"C38355\"}}",
         :headers => {'Authorization'=>'Basic ', 'Content-Type'=>'application/json', 'User-Agent'=>'test'}).
        to_return(:status => 200, :body => "", :headers => {})
    end

    # def stub_retries_accepted
    #   skip 'fill in rest of stub'
    #   stub_request(:get, "www.example.com").
    #     to_timeout.then.
    #     to_timeout.then.
    #     to_return(
    #       status:  ok,
    #       body:    File.read('.'),
    #       headers: response_headers
    #     )
    # end

  end
end



module Stub
  module Payloads

    def workflows_search
      {
        filters: [
          {
            name:     'applicantworkflow.customfield4006.text',
            value:    [],
            operator: '='
          },
          {
            name:     'applicantworkflow.customfield4007.text',
            value:    [],
            operator: '='
          },
          {
            name:     'applicantworkflow.customfield3300.text',
            value:    ['135'],
            operator: '='
          },
          {
            name:     'applicantworkflow.person.createddate',
            value:    ['2013-03-25 4:00 AM'],
            operator: '<'
          }
        ],
        operator: '&'
      }
    end

    def create_workflow(job_id: , person_id: )
      {
        baseprofile:       job_id,
        associatedprofile: person_id,
        status: { id: 'C38356' },
        source:     'Other (Please Specify)',
        sourcename: 'org.mapc.youthjobs.lottery',
      }
    end

    def jobs_search
      {
        filters: [
          { name: 'job.numberofpositions', value: ['1'],  operator: '>=' },
          { name: 'job.postedto', value: ['Successlink'], operator: '='  }
        ],
        operator: '&'
      }
    end

  end
end

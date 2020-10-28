require 'spec_helper'

describe TableauApi::Resources::Jobs, vcr: { cassette_name: 'jobs' } do
  include_context 'tableau client'

  describe '#list' do
    # https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_ref_jobstasksschedules.htm#query_jobs
    it 'can list jobs in a site' do
      jobs = client.jobs.list
      expect(jobs).to eq('FIXME')
    end

    it 'can apply a filter to list jobs in a site' do
      jobs = client.jobs.list(filter: 'jobType:eq:not_extract_refresh')
      expect(jobs).to eq('FIXME')
    end
  end
end

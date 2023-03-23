# frozen_string_literal: true

require 'spec_helper'

describe TableauApi::Resources::Jobs, vcr: { cassette_name: 'jobs' } do
  include_context 'tableau client'

  def find_or_publish_workbook(name)
    project = client.projects.list.find { |p| p['name'] == 'test' }
    workbook = client.workbooks.list.find { |w| w['name'] == name }

    if workbook
      workbook = client.workbooks.find(workbook['id'])
      return workbook
    end

    client.workbooks.publish(
      name: name,
      project_id: project['id'],
      file: 'spec/fixtures/workbooks/test.twbx',
      overwrite: true
    )
  end

  describe '#list' do
    # https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_ref_jobstasksschedules.htm#query_jobs
    it 'can list jobs in a site' do
      workbook = find_or_publish_workbook('test')
      client.workbooks.refresh(workbook_id: workbook['id'])
      jobs = client.jobs.list
      expect(jobs.to_a.last.keys).to include('createdAt', 'id', 'jobType', 'priority', 'status')
    end

    it 'can filter jobs in a site' do
      workbook = find_or_publish_workbook('test')
      client.workbooks.refresh(workbook_id: workbook['id'])
      jobs = client.jobs.list(query: 'filter=jobType:eq:refresh_extracts,status:eq:Success')
      expect(jobs.to_a).to be_empty
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe TableauApi::Resources::Projects, vcr: { cassette_name: 'projects' } do
  include_context 'tableau client'

  # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Create_Project%3FTocPath%3DAPI%2520Reference%7C_____13
  it 'can create a project in a site' do
    project = client.projects.create(name: 'test_project')
    expect(project['id']).to be_a_tableau_id
    expect(project).to eq(
      'id' => project['id'],
      'name' => 'test_project',
      'description' => '',
      'contentPermissions' => 'ManagedByOwner',
      'owner' => project['owner'],
      'updatedAt' => project['updatedAt'],
      'createdAt' => project['createdAt']
    )
  end

  it 'can list projects' do
    sleep(15) if VCR.current_cassette.recording?
    project = client.projects.list.find do |p|
      p['name'] == 'test_project'
    end
    expect(project['id']).to be_a_tableau_id
    expect(project).to eq(
      'id' => project['id'],
      'name' => 'test_project',
      'description' => '',
      'contentPermissions' => 'ManagedByOwner',
      'owner' => project['owner'],
      'updatedAt' => project['updatedAt'],
      'createdAt' => project['createdAt']
    )
  end
end

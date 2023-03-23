# frozen_string_literal: true

require 'spec_helper'
describe TableauApi::Resources::Datasources, vcr: { cassette_name: 'datasources' } do
  include_context 'tableau client'

  # https://onlinehelp.tableau.com/current/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Datasources%3FTocPath%3DAPI%2520Reference%7C_____48

  it 'can list datasources' do
    datasource = client.datasources.list.find do |d|
      d['name'] == 'test'
    end
    expect(datasource['id']).to be_a_tableau_id
    expect(datasource).to eq(
      'id' => datasource['id'],
      'name' => 'test',
      'contentUrl' => 'test',
      'createdAt' => datasource['createdAt'],
      'updatedAt' => datasource['updatedAt'],
      'owner' => { 'id' => datasource['owner']['id'] },
      'project' => {
        'id' => datasource['project']['id'],
        'name' => datasource['project']['name']
      },
      'type' => 'textscan',
      'tags' => nil,
      'isCertified' => 'false',
      'webpageUrl' => datasource['webpageUrl']
    )
  end
end

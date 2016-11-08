require 'spec_helper'
describe TableauApi::Resources::Datasources, vcr: { cassette_name: 'datasources' } do
  include_context 'tableau client'

  # https://onlinehelp.tableau.com/current/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Datasources%3FTocPath%3DAPI%2520Reference%7C_____48

  it 'can list datasources' do
    datasource = client.datasources.list.find do |d|
      d['name'] == 'test'
    end
    expect(datasource['id']).to be_a_tableau_id
    expect(datasource).to eq('id' => datasource['id'], 'name' => 'test', 'description' => '')
  end
end
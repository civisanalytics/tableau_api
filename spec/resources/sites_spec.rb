require 'spec_helper'

describe TableauApi::Resources::Sites, vcr: { cassette_name: 'sites' } do
  include_context 'tableau client'

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Sites%3FTocPath%3DAPI%2520Reference%7C_____40
    it 'can list sites' do
      sites = client.sites.list.to_a

      expect(sites.length).to eq 2

      site = sites.find do |s|
        s['contentUrl'] == 'TestSite'
      end

      expect(site['id']).to be_a_tableau_id
      expect(site).to eq(
        'id' => site['id'],
        'name' => 'Test Site',
        'contentUrl' => 'TestSite',
        'adminMode' => 'ContentAndUsers',
        'state' => 'Active'
      )
    end
  end
end

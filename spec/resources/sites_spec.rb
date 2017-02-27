require 'spec_helper'

describe TableauApi::Resources::Sites, vcr: { cassette_name: 'sites' } do
  include_context 'tableau client'

  describe '#create' do
    let(:default_client) do
      TableauApi.new(
        host: ENV['TABLEAU_HOST'],
        site_name: 'Default',
        username: ENV['TABLEAU_ADMIN_USERNAME'],
        password: ENV['TABLEAU_ADMIN_PASSWORD']
      )
    end

    it 'can create a site' do
      site = default_client.sites.create(name: 'Test Site 2', content_url: 'TestSite2', admin_mode: 'ContentAndUsers')
      expect(site).not_to be_nil
      expect(site['id']).to be_a_tableau_id
      expect(site).to eq(
        'id' => site['id'],
        'name' => 'Test Site 2',
        'contentUrl' => 'TestSite2',
        'adminMode' => 'ContentAndUsers',
        'state' => 'Active',
        'disableSubscriptions' => 'true'
      )
    end
  end

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Sites%3FTocPath%3DAPI%2520Reference%7C_____40
    it 'can list sites' do
      sites = client.sites.list.to_a

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

  describe '#delete' do
    let(:site_client) do
      TableauApi.new(
        host: ENV['TABLEAU_HOST'],
        site_name: 'TestSite2',
        username: ENV['TABLEAU_ADMIN_USERNAME'],
        password: ENV['TABLEAU_ADMIN_PASSWORD']
      )
    end

    it 'can delete a site' do
      site = site_client.sites.list.to_a.find do |s|
        s['name'] == 'Test Site 2'
      end
      expect(site_client.sites.delete(site_id: site['id'])).to be true
    end
  end
end

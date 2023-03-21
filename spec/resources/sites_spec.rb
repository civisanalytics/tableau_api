# frozen_string_literal: true

require 'spec_helper'

describe TableauApi::Resources::Sites, vcr: { cassette_name: 'sites' } do
  include_context 'tableau client'

  let(:default_client) do
    TableauApi.new(
      host: ENV.fetch('TABLEAU_HOST', nil),
      site_name: 'Default',
      username: ENV.fetch('TABLEAU_ADMIN_USERNAME', nil),
      password: ENV.fetch('TABLEAU_ADMIN_PASSWORD', nil)
    )
  end

  describe '#create' do
    it 'can create a site' do
      site = default_client.sites.create(name: 'Test Site 2', content_url: 'TestSite2', admin_mode: 'ContentAndUsers')
      expect(site['id']).to be_a_tableau_id
      expect(site).to eq(
        'id' => site['id'],
        'name' => 'Test Site 2',
        'contentUrl' => 'TestSite2',
        'adminMode' => 'ContentAndUsers',
        'state' => 'Active',
        'disableSubscriptions' => 'false',
        'cacheWarmupEnabled' => 'true',
        'commentingEnabled' => 'true',
        'guestAccessEnabled' => 'true',
        'revisionHistoryEnabled' => 'true',
        'revisionLimit' => '25',
        'subscribeOthersEnabled' => 'true'
      )
    end

    it 'raises an error if fails to create a site' do
      expect do
        default_client.sites.create(name: 'Test Site 3', content_url: 'TestSite2', admin_mode: 'ContentAndUsers')
      end.to raise_error(TableauApi::TableauError)
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
        'name' => 'TestSite',
        'contentUrl' => 'TestSite',
        'adminMode' => 'ContentAndUsers',
        'state' => 'Active',
        'cacheWarmupEnabled' => 'true',
        'commentingEnabled' => 'true',
        'guestAccessEnabled' => 'false',
        'revisionHistoryEnabled' => 'true',
        'revisionLimit' => '25',
        'subscribeOthersEnabled' => 'true',
        'disableSubscriptions' => 'true'
      )
    end
  end

  describe '#delete' do
    let(:site_client) do
      TableauApi.new(
        host: ENV.fetch('TABLEAU_HOST', nil),
        site_name: 'TestSite2',
        username: ENV.fetch('TABLEAU_ADMIN_USERNAME', nil),
        password: ENV.fetch('TABLEAU_ADMIN_PASSWORD', nil)
      )
    end

    it 'can delete a site' do
      site = site_client.sites.list.to_a.find do |s|
        s['name'] == 'Test Site 2'
      end
      expect(site_client.sites.delete(site_id: site['id'])).to be true
    end

    it 'raises an error if fails to delete a site' do
      expect do
        default_client.sites.delete(site_id: 'does-not-exist')
      end.to raise_error(TableauApi::TableauError)
    end
  end
end

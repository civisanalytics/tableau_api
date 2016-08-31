require 'spec_helper'

describe TableauApi::Resources::Groups do
  include_context 'tableau client'

  describe '#create' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Create_Group
    it 'can create a group in a site' do
      VCR.use_cassette('groups') do
        group = client.groups.create(name: 'testgroup')
        expect(groups['id']).to be_a_tableau_id
        expect(groups).to eq('id' => group['id'], 'name' => 'testgroup', 'defaultSiteRole' => 'Viewer')
      end
    end

    it 'fails with a bad site_role' do
      VCR.use_cassette('groups') do
        expect { client.groups.create(name: 'test', default_site_role: 'foo') }.to raise_error('invalid default_site_role')
      end
    end
  end

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Groups
    it 'can list groups in a site' do
      VCR.use_cassette('groups') do
        group = client.groups.list.find do |g|
          g['name'] == 'testgroup'
        end
        expect(group['id']).to be_a_tableau_id
        expect(group).to eq('id' => group['id'], 'name' => 'testgroup', 'defaultSiteRole' => 'Viewer')
      end
    end
  end
end

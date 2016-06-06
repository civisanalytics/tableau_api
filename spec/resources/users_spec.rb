require 'spec_helper'

describe TableauApi::Resources::Users do
  include_context 'tableau client'

  describe '#create' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Add_User_to_Site%3FTocPath%3DAPI%2520Reference%7C_____7
    it 'can create a user in a site' do
      VCR.use_cassette('users') do
        user = client.users.create(username: 'test')
        expect(user['id']).to be_a_tableau_id
        expect(user).to eq('id' => user['id'], 'name' => 'test', 'siteRole' => 'Viewer')
      end
    end

    it 'fails with a bad site_role' do
      VCR.use_cassette('users') do
        expect { client.users.create(username: 'test', site_role: 'foo') }.to raise_error('invalid site_role')
      end
    end
  end

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Get_Users_on_Site
    it 'can list users in a site' do
      VCR.use_cassette('users') do
        user = client.users.list.find do |u|
          u['name'] == 'test'
        end
        expect(user['id']).to be_a_tableau_id
        expect(user).to eq('id' => user['id'], 'name' => 'test', 'siteRole' => 'Viewer', 'externalAuthUserId' => '')
      end
    end
  end
end

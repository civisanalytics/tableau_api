require 'spec_helper'

describe TableauApi::Resources::Users, vcr: { cassette_name: 'users' } do
  include_context 'tableau client'

  describe '#create' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Add_User_to_Site%3FTocPath%3DAPI%2520Reference%7C_____7
    it 'can create a user in a site' do
      user = client.users.create(username: 'test')
      expect(user['id']).to be_a_tableau_id
      expect(user).to eq(
        'id' => user['id'],
        'name' => 'test',
        'siteRole' => 'Unlicensed',
        'externalAuthUserId' => '',
        'authSetting' => 'ServerDefault'
      )
    end

    it 'fails with a bad site_role' do
      expect { client.users.create(username: 'test', site_role: 'foo') }.to raise_error('invalid site_role')
    end
  end

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Get_Users_on_Site
    it 'can list users in a site' do
      user = client.users.list.find do |u|
        u['name'] == 'test'
      end
      expect(user['id']).to be_a_tableau_id
      expect(user).to eq('id' => user['id'], 'name' => 'test', 'siteRole' => 'Unlicensed', 'externalAuthUserId' => '')
    end
  end

  describe '#update_user' do
    # https://onlinehelp.tableau.com/current/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Update_User
    it 'can change the site role of a user in a site' do
      user = client.users.list.find do |u|
        u['name'] == 'test'
      end
      expect(user['siteRole']).to eq('Unlicensed')
      user_after_change = client.users.update_user(user_id: user['id'], site_role: 'Publisher')
      expect(user_after_change['siteRole']).to eq('Publisher')
    end

    it 'raises an error if the site role is not valid' do
      user = client.users.list.find do |u|
        u['name'] == 'test'
      end
      expect do
        client.users.update_user(user_id: user['id'], site_role: 'foo')
      end.to raise_error(RuntimeError, 'invalid site_role')
    end

    it 'raises an error if the user cannot be found' do
      expect do
        client.users.update_user(user_id: 'foo', site_role: 'Viewer')
      end.to raise_error(RuntimeError, 'failed to find user')
    end
  end
end

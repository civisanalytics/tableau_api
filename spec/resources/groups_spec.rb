require 'spec_helper'

describe TableauApi::Resources::Groups do
  include_context 'tableau client'

  describe '#create' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Create_Group
    it 'fails with a bad site_role' do
      VCR.use_cassette('groups') do
        expect { client.groups.create(name: 'test', default_site_role: 'foo') }.to raise_error('invalid default_site_role')
      end
    end

    it 'can create a group in a site' do
      VCR.use_cassette('groups') do
        group = client.groups.create(name: 'testgroup')
        expect(group['id']).to be_a_tableau_id
        expect(group).to eq('id' => group['id'], 'name' => 'testgroup')
      end
    end
  end

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Groups
    it 'can list groups in a site' do
      VCR.use_cassette('groups') do
        group = find_group_by_name('testgroup')
        expect(group).to eq('id' => group['id'], 'name' => 'testgroup', 'domain' => { 'name' => 'local' })
      end
    end
  end

  describe '#add_user' do
    it 'can add a user to a group' do
      VCR.use_cassette('groups') do
        group = find_group_by_name('testgroup')
        expect(client.groups.add_user(group_id: group['id'], user_id: 'e1b91057-9cd9-4009-b6c9-cd18f1dc3fb4')).to be true
      end
    end
  end

  describe '#remove_user' do
    it 'can remove a user from a group' do
      VCR.use_cassette('groups') do
        group = find_group_by_name('testgroup')
        expect(client.groups.remove_user(group_id: group['id'], user_id: 'e1b91057-9cd9-4009-b6c9-cd18f1dc3fb4')).to be true
      end
    end
  end

  def find_group_by_name(name)
    group = client.groups.list.find do |g|
      g['name'] == name
    end
    expect(group['id']).to be_a_tableau_id
    group
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe TableauApi::Resources::Groups, vcr: { cassette_name: 'groups' } do
  include_context 'tableau client'

  let(:test_user_id) do
    user = client.users.list.find do |u|
      u['name'] == 'test'
    end
    user['id']
  end

  describe '#create' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Create_Group
    it 'fails with a bad site_role' do
      expect { client.groups.create(name: 'test', default_site_role: 'foo') }.to raise_error('invalid default_site_role')
    end

    it 'can create a group in a site' do
      group = client.groups.create(name: 'testgroup')
      expect(group['id']).to be_a_tableau_id
      expect(group).to eq('id' => group['id'], 'name' => 'testgroup')
    end
  end

  describe '#list' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Query_Groups
    it 'can list groups in a site' do
      sleep(15) if VCR.current_cassette.recording?
      group = find_group_by_name('testgroup')
      expect(group).to eq('id' => group['id'], 'name' => 'testgroup', 'domain' => { 'name' => 'local' })
      expect(group['id']).to be_a_tableau_id
    end
  end

  describe '#add_user' do
    it 'can add a user to a group' do
      group = find_group_by_name('testgroup')
      expect(client.groups.add_user(group_id: group['id'], user_id: test_user_id)).to be true
    end
  end

  describe '#users' do
    it 'can get the users in a group' do
      group = find_group_by_name('testgroup')
      users = client.groups.users(group_id: group['id'])
      expect(users.map { |u| u['id'] }.include?(test_user_id)).to be true
    end
  end

  describe '#remove_user' do
    it 'can remove a user from a group' do
      group = find_group_by_name('testgroup')
      expect(client.groups.remove_user(group_id: group['id'], user_id: test_user_id)).to be true
    end
  end

  def find_group_by_name(name)
    client.groups.list.find do |g|
      g['name'] == name
    end
  end
end

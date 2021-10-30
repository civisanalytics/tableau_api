require 'spec_helper'

describe TableauApi::Resources::Auth, vcr: { cassette_name: 'auth' } do
  let(:client) do
    TableauApi.new(
      host: ENV['TABLEAU_HOST'],
      site_name: 'Default',
      username: ENV['TABLEAU_ADMIN_USERNAME'],
      password: ENV['TABLEAU_ADMIN_PASSWORD']
    )
  end

  describe 'username and password' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_concepts_auth.htm%3FTocPath%3DConcepts%7C_____3
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Sign_In%3FTocPath%3DAPI%2520Reference%7C_____51
    it 'returns an instance of TableauApi::Resources::Auth' do
      client = TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername', password: 'ExamplePassword')
      expect(client.auth).to be_an_instance_of(TableauApi::Resources::Auth)
    end

    it 'fails appropriately with a bad username or password' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'Default', username: 'foo', password: 'bar')
      expect(client.auth.sign_in).to be false
    end

    it 'automatically signs in to get the token' do
      expect(client.auth.token).to be_a_token
    end

    it 'sucessfully signs in with a correct username and password' do
      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to be_a_token
      expect(client.auth.site_id).to be_a_tableau_id
      expect(client.auth.user_id).to be_a_tableau_id
    end

    it 'signs into a different site' do
      client = TableauApi.new(
        host: ENV['TABLEAU_HOST'],
        site_name: 'TestSite',
        username: ENV['TABLEAU_ADMIN_USERNAME'],
        password: ENV['TABLEAU_ADMIN_PASSWORD']
      )
      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to be_a_token
      expect(client.auth.site_id).to be_a_tableau_id
      expect(client.auth.user_id).to be_a_tableau_id
    end

    it 'does not sign in if already signed in' do
      expect(client.auth.sign_in).to be true
      token = client.auth.token

      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to eq token
    end
  end

  describe 'personal access token' do
    let(:client) do
      TableauApi.new(
        host: ENV['TABLEAU_HOST'],
        site_name: 'Default',
        personal_access_token_name: ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME'],
        personal_access_token_secret: ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET']
      )
    end

    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_concepts_auth.htm%3FTocPath%3DConcepts%7C_____3
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Sign_In%3FTocPath%3DAPI%2520Reference%7C_____51
    it 'returns an instance of TableauApi::Resources::Auth' do
      client = TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', personal_access_token_name: 'ExamplePersonalAccessTokenName', personal_access_token_secret: 'ExamplePersonalAccessTokenSecret')
      expect(client.auth).to be_an_instance_of(TableauApi::Resources::Auth)
    end

    it 'fails appropriately with a bad access token credentials' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'Default', personal_access_token_name: 'foo', personal_access_token_secret: 'bar')
      expect(client.auth.sign_in).to be false
    end

    it 'automatically signs in to get the token' do
      expect(client.auth.token).to be_a_token
    end

    it 'sucessfully signs in with a correct username and password' do
      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to be_a_token
      expect(client.auth.site_id).to be_a_tableau_id
      expect(client.auth.user_id).to be_a_tableau_id
    end

    it 'signs into a different site' do
      client = TableauApi.new(
        host: ENV['TABLEAU_HOST'],
        site_name: 'TestSite',
        personal_access_token_name: ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME'],
        personal_access_token_secret: ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET']
      )
      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to be_a_token
      expect(client.auth.site_id).to be_a_tableau_id
      expect(client.auth.user_id).to be_a_tableau_id
    end

    it 'does not sign in if already signed in' do
      expect(client.auth.sign_in).to be true
      token = client.auth.token

      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to eq token
    end
  end

  describe '.sign_out' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Sign_Out
    it 'can sign out' do
      expect(client.auth.sign_in).to be true
      expect(client.auth.token).to be_a_token
      expect(client.auth.site_id).to be_a_tableau_id
      expect(client.auth.user_id).to be_a_tableau_id
      expect(client.auth.sign_out).to be true
      # accessing the token automatically signs in
      expect(client.auth.instance_variable_get('@token')).to be nil
      expect(client.auth.instance_variable_get('@site_id')).to be nil
      expect(client.auth.instance_variable_get('@user_id')).to be nil
    end

    it 'can sign out with a bad token' do
      expect(client.auth.sign_in).to be true
      client.auth.instance_variable_set('@token', 'foo')
      expect(client.auth.sign_out).to be true
      expect(client.auth.instance_variable_get('@token')).to be nil
      expect(client.auth.instance_variable_get('@site_id')).to be nil
      expect(client.auth.instance_variable_get('@user_id')).to be nil
    end
  end

  describe '.trusted_ticket' do
    it 'can get a trusted ticket' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'Default', username: 'test')
      expect(client.auth.trusted_ticket).to be_a_trusted_ticket
    end

    it 'can get a trusted ticket for a non default site' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'test', username: 'test_test')
      expect(client.auth.trusted_ticket).to be_a_trusted_ticket
    end

    it 'fails with a user not in a site' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'test', username: 'test')
      expect(client.auth.trusted_ticket).to be nil
    end

    it 'fails with a bad user' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'Default', username: 'invalid_user')
      expect(client.auth.trusted_ticket).to be nil
    end

    it 'fails with a bad site' do
      client = TableauApi.new(host: ENV['TABLEAU_HOST'], site_name: 'invalid_site', username: 'test')
      expect(client.auth.trusted_ticket).to be nil
    end
  end
end

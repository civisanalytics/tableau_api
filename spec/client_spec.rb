require 'spec_helper'

describe TableauApi::Client do
  it 'can create a client without issuing any web requests' do
    # this would exception if this made any http requests because VCR is set to not allow http connections when no cassette is loaded
    client = TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername', password: 'ExamplePassword')
    expect(client).to be_an_instance_of(TableauApi::Client)
  end

  it 'requires the host, site_name, and one of username or personal_access_token_name' do
    expect { TableauApi.new(host: nil, site_name: 'bar', username: 'baz') }.to raise_error('host is required')
    expect { TableauApi.new(host: '', site_name: 'bar', username: 'baz') }.to raise_error('host is required')

    expect { TableauApi.new(host: 'foo', site_name: nil, username: 'baz') }.to raise_error('site_name is required')
    expect { TableauApi.new(host: 'foo', site_name: '', username: 'baz') }.to raise_error('site_name is required')

    expect { TableauApi.new(host: 'foo', site_name: 'bar', username: nil) }.to raise_error('username or personal_access_token_name is required')
    expect { TableauApi.new(host: 'foo', site_name: 'bar', username: '') }.to raise_error('username or personal_access_token_name is required')

    expect { TableauApi.new(host: 'foo', site_name: 'bar', personal_access_token_name: nil) }.to raise_error('username or personal_access_token_name is required')
    expect { TableauApi.new(host: 'foo', site_name: 'bar', personal_access_token_name: '') }.to raise_error('username or personal_access_token_name is required')
  end

  it 'provides info about the authentication type based on params' do
    expect(TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', personal_access_token_name: 'ExampleTokenName', personal_access_token_secret: 'ExampleTokenSecret').authentication_type).to eq(TableauApi::Client::AUTH_TYPE_PERSONAL_ACCESS_TOKEN)
    expect(TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername').authentication_type).to eq(TableauApi::Client::AUTH_TYPE_TRUSTED_TICKET)
    expect(TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername', password: 'ExamplePassword').authentication_type).to eq(TableauApi::Client::AUTH_TYPE_USERNAME_AND_PASSWORD)
  end
end

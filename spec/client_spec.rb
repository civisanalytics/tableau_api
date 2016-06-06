require 'spec_helper'

describe TableauApi::Client do
  it 'can create a client without issuing any web requests' do
    # this would exception if this made any http requests because VCR is set to not allow http connections when no cassette is loaded
    client = TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername', password: 'ExamplePassword')
    expect(client).to be_an_instance_of(TableauApi::Client)
  end

  it 'requires the host, site_name, and username' do
    expect { TableauApi.new(host: nil, site_name: 'bar', username: 'baz') }.to raise_error('host is required')
    expect { TableauApi.new(host: '', site_name: 'bar', username: 'baz') }.to raise_error('host is required')

    expect { TableauApi.new(host: 'foo', site_name: nil, username: 'baz') }.to raise_error('site_name is required')
    expect { TableauApi.new(host: 'foo', site_name: '', username: 'baz') }.to raise_error('site_name is required')

    expect { TableauApi.new(host: 'foo', site_name: 'bar', username: nil) }.to raise_error('username is required')
    expect { TableauApi.new(host: 'foo', site_name: 'bar', username: '') }.to raise_error('username is required')
  end
end

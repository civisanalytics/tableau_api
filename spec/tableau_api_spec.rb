# frozen_string_literal: true

require 'spec_helper'

describe TableauApi do
  it 'has a version number' do
    expect(TableauApi::VERSION).not_to be nil
  end

  it 'can create a client from TableauApi' do
    expect(TableauApi.new(host: 'tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername')).to be_an_instance_of(TableauApi::Client)
  end
end

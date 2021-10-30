$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tableau_api'

require 'pry'

require 'vcr'

if ENV['TABLEAU_ADMIN_USERNAME'].nil? ||
  ENV['TABLEAU_ADMIN_PASSWORD'].nil? ||
  ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME'].nil? ||
  ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET'].nil?
  puts 'TABLEAU_ADMIN_USERNAME, TABLEAU_ADMIN_PASSWORD, TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME, and TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET must be set to record new VCR cassettes'

  ENV['TABLEAU_ADMIN_USERNAME'] = 'FakeTableauAdminUsername'
  ENV['TABLEAU_ADMIN_PASSWORD'] = 'FakeTableauAdminPassword'
  ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME'] = 'FakeTableauAdminPersonalAccessTokenName'
  ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET'] = 'FakeTableauAdminPersonalAccessTokenSecret'
end

ENV['TABLEAU_HOST'] = 'http://localhost:2000' if ENV['TABLEAU_HOST'].nil?

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock

  config.default_cassette_options = { record: :new_episodes, match_requests_on: %i[path method body query] }

  config.filter_sensitive_data('TABLEAU_ADMIN_USERNAME') { ENV['TABLEAU_ADMIN_USERNAME'] }
  config.filter_sensitive_data('TABLEAU_ADMIN_PASSWORD') { ENV['TABLEAU_ADMIN_PASSWORD'].encode(xml: :text) }
  config.filter_sensitive_data('TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME') { ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME'] }
  config.filter_sensitive_data('TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET') { ENV['TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET'].encode(xml: :text) }
  config.filter_sensitive_data('http://TABLEAU_HOST') { ENV['TABLEAU_HOST'] }

  config.allow_http_connections_when_no_cassette = false

  # only record a whitelist of test site and user elements
  config.before_record do |interaction|
    response = interaction.response
    elements = response.body.scan(/<(?:site|user)\s[^>]+name[^>]+>/)
    sensitive_elements = elements.reject { |e| e.match(/"(Default|TestSite|Test Site 2|test|test_test|TABLEAU_ADMIN_USERNAME|TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME)"/) }
    unless sensitive_elements.empty?
      sensitive_elements.each { |e| response.body.gsub! e, '' }
      response.body.gsub!(/totalAvailable="\d+"/, "totalAvailable=\"#{elements.length - sensitive_elements.length}\"")
    end
    raise 'Cassette might contain sensitive data; does a regex need to be updated?' if response.body =~ /civis/i
  end
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  # Turn deprecation warnings into errors.
  config.raise_errors_for_deprecations!

  # Persist example state. Enables --only-failures:
  # http://rspec.info/blog/2015/06/rspec-3-3-has-been-released/#core-new---only-failures-option
  config.example_status_persistence_file_path = 'tmp/examples.txt'
  config.run_all_when_everything_filtered = true
end

RSpec::Matchers.define :be_a_tableau_id do
  match do |actual|
    actual.match(/\A\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\z/)
  end
end

RSpec::Matchers.define :be_a_token do
  match do |actual|
    actual.match(/\A\w{32}\z/) || actual.match(/\A[\w-]{22}\|\w{32}\z/)
  end
end

RSpec::Matchers.define :be_a_trusted_ticket do
  match do |actual|
    actual.match(/\A[\w-]{24}\z/) || actual.match(/\A[\w\-=]{24}:[\w-]{24}\z/)
  end
end

RSpec.shared_context 'tableau client' do
  let(:client) do
    TableauApi.new(
      host: ENV['TABLEAU_HOST'],
      site_name: 'TestSite',
      username: ENV['TABLEAU_ADMIN_USERNAME'],
      password: ENV['TABLEAU_ADMIN_PASSWORD']
    )
  end
end

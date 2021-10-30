# tableau_api

[![Build Status](https://travis-ci.org/civisanalytics/tableau_api.svg?branch=master)](https://travis-ci.org/civisanalytics/tableau_api)
[![Gem Version](https://badge.fury.io/rb/tableau_api.svg)](http://badge.fury.io/rb/tableau_api)

Ruby interface to the Tableau 9.0 API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tableau_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tableau_api

## Usage

### Basic Authentication
```
client = TableauApi.new(host: 'https://tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername', password: 'ExamplePassword')
client.users.create(username: 'baz')
```

### Trusted Authentication
```
client = TableauApi.new(host: 'https://tableau.domain.tld', site_name: 'Default', username: 'ExampleUsername')
client.auth.trusted_ticket
```

### Personal Access Token Authentication
```
client = TableauApi.new(host: 'https://tableau.domain.tld', site_name: 'Default', personal_access_token_name: 'ExampleTokenName', personal_access_token_secret: 'ExampleTokenSecret')
client.users.create(username: 'baz')
```

### Workbooks
```
# find a workbook by name
workbook = client.workbooks.list.find do |w|
  w['name'] == 'Example Workbook Name'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests and linters. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

### Docker

```
docker run -it -d -v $(pwd):/src ruby /bin/bash
docker exec -it CONTAINER_ID /bin/bash -c "cd /src && bundle && rake"
```

### Creating New VCR Cassettes

Cassettes should be self-contained, generated by a single spec file
run in defined order. To make changes to specs, it's best to delete a whole cassette
and rerun the whole spec file, except for auth.yml, since it could be difficult to
generate a trusted ticket from a non-trusted host.

To regenerate all the the cassettes, you'll first need to create the following on the Tableau server:
* *Site*: Default
* *Site*: TestSite
 * *Datasource*: test (this might need to be created from Tableau Desktop)
 * *Username*: test_test

And delete the following if they exist:
* *Group*: testgroup (probably under TestSite)
* *Project*: test_project (probably under Default)
* *Site*: Test Site 2
* *User*: test (probably under TestSite)
* *Workbook*: test
* *Workbook*: testpublish

Set the environment variables below to an administrator account and your Tableau Server hostname.

Then run the commands below:

```
docker run -it -d \
  -v $(pwd):/src \
  -e TABLEAU_HOST -e TABLEAU_ADMIN_USERNAME -e TABLEAU_ADMIN_PASSWORD \
  -e TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_NAME -e TABLEAU_ADMIN_PERSONAL_ACCESS_TOKEN_SECRET \
  ruby /bin/bash
docker exec -it CONTAINER_ID /bin/bash -c "cd /src && bundle && rake"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/civisanalytics/tableau_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

tableau_api is released under the [BSD 3-Clause License](LICENSE.txt).

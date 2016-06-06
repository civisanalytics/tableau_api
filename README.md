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

Set the environment variables below to an administrator account, create a tunnel
to your tableau server on port 2000, then run the commands below.

```
docker run -it -d \
  -v $(pwd):/src \
  --add-host=docker:$(ifconfig en0 | grep 'inet\b' | cut -d ' ' -f 2) \
  -e TABLEAU_HOST='http://docker:2000' -e TABLEAU_ADMIN_USERNAME -e TABLEAU_ADMIN_PASSWORD \
  ruby /bin/bash
docker exec -it CONTAINER_ID /bin/bash -c "cd /src && bundle && rake"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/civisanalytics/tableau_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

tableau_api is released under the [BSD 3-Clause License](LICENSE.txt).

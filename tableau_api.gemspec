# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tableau_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'tableau_api'
  spec.version       = TableauApi::VERSION
  spec.authors       = ['Christopher Manning', 'Matt Brennan',
                        'Jonathan Cobian']
  spec.email         = ['opensource@civisanalytics.com']

  spec.summary       = 'Ruby interface to the Tableau API.'
  spec.homepage      = 'https://github.com/civisanalytics/tableau_api'
  spec.license       = 'BSD-3-Clause'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'httparty', '~> 0.13'
  spec.add_dependency 'builder', '~> 3.2'
  spec.add_dependency 'multipart-post', '~> 2.0'
  spec.add_dependency 'rubyzip', '>= 1.0'

  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'pry-byebug', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.49.0'
  spec.add_development_dependency 'chunky_png', '~> 1.3.11'
end

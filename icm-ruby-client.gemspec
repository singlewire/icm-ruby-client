# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icm_ruby_client/version'

Gem::Specification.new do |spec|
  spec.name = 'icm-ruby-client'
  spec.version = ICMClient::VERSION
  spec.authors = ['Vincent Pizzo']
  spec.email = %w(vincent.pizzo@singlewire.com)
  spec.description = %q{A simple ruby client for InformaCast Mobile.}
  spec.summary = %q{A simple ruby client for InformaCast Mobile based on the popular rest-client.}
  spec.homepage = 'https://github.com/singlewire/icm-ruby-client'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($/)
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'rest-client', '~> 1.7.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'webmock', '~> 1.21.0'
  spec.add_development_dependency 'rspec', '~> 3.2.0'

  spec.required_ruby_version = '>= 1.9.3'
end

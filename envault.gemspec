# -*- encoding: utf-8 -*-

require File.expand_path('../lib/envault/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "envault"
  gem.version       = Envault::VERSION
  gem.summary       = %q{Encrypt secret information environment variables by yaml.}
  gem.description   = %q{Encrypt secret information environment variables by yaml.}
  gem.license       = "MIT"
  gem.authors       = ["toyama0919"]
  gem.email         = "toyama0919@gmail.com"
  gem.homepage      = "https://github.com/toyama0919/envault"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.1'

  gem.add_dependency 'thor'
  gem.add_dependency 'dotenv'
  gem.add_dependency 'activesupport', ">= 4.0.0"

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop', '~> 0.24.1'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.8'
end

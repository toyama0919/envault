source 'https://rubygems.org'

gemspec

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.2")
  # NOTE: activesupport 5.x supports only ruby 2.2.2+
  gem "activesupport", ">= 4.0.0", "< 5.0.0"
end

group :development do
  gem 'kramdown'
end

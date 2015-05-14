source 'https://rubygems.org'

# The core framework
# https://github.com/rails/rails
gem 'rails', '4.1.8'

gem 'actionpack-action_caching', '~>1.1.1'
gem 'actionpack-page_caching', '~>1.0.2'
gem 'actionpack-xml_parser', '~>1.0.1'
gem 'actionview-encoded_mail_to', '~>1.0.5'
gem 'activerecord-session_store', '~>0.1.1'
gem 'activeresource', '~>4.0.0'
gem 'protected_attributes', '~> 1.0.8'
gem 'rails-observers', '~>0.1.2'
gem 'rails-perftest', '~>0.0.5'

gem 'activerecord-jdbc-adapter', '~> 1.3.16'

# Postgresql adapter
gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.16'

# H2 adapter
gem 'activerecord-jdbch2-adapter', '~> 1.3.16'

# A JSON implementation as a Ruby extension in C
# http://flori.github.com/json/
gem 'json', '~> 1.8.0'

# CAS Strategy for OmniAuth
# https://rubygems.org/gems/omniauth-cas
gem 'omniauth-cas', '~> 1.1.0'

# LDAP
gem 'net-ldap', '~> 0.11.0'

# secure_headers provides x-frame, csp and other http headers
gem 'secure_headers', '~> 1.4.0'

gem 'faraday', '~> 0.9.0'
gem 'faraday_middleware', '~> 0.9.1'
gem 'httparty', '~> 0.13.3'

# OAuth2 support
gem 'signet', '~> 0.6.0'
gem 'google-api-client', '~> 0.8.6'

# LTI support
gem 'ims-lti', :git => 'https://github.com/instructure/ims-lti.git'

# for VCR http recording tool
gem 'vcr', '~> 2.9.3'
# Replace with this line for a new recording, if you truly must make a new recording.
# gem 'vcr', :git => 'https://github.com/vcr/vcr.git'

# for memcached connection
gem 'dalli', '~> 2.7.2'

# smarter logging
gem 'log4r', '~> 1.1'

# for easier non-DB-backed models
gem 'active_attr', '~> 0.8.5'

# for production deployment
gem 'jruby-activemq', '~> 5.5.1'

# Addressable is a replacement for the URI implementation that is part of Ruby's standard library.
# https://github.com/sporkmonger/addressable
gem 'addressable', '~> 2.3.4'

# for parsing formatted html
# Do NOT update until https://github.com/sparklemotion/nokogiri/issues/1114 is fixed
gem 'nokogiri', '~> 1.5.9', :platforms => :jruby

# for parsing paged feeds
gem 'link_header', '~> 0.0.7'

# for simplified relational data management
gem 'rails_admin', '0.6.5'

gem 'bootstrap-sass', '~> 3.3.1.0'

# TorqueBox app server
gem 'torquebox', '~> 3.1.2'
gem 'torquebox-server', '~> 3.1.2'
gem 'torquebox-messaging', '~> 3.1.2'

# for trying, and trying again, and then giving up.
gem 'retriable', '~> 1.4'

# authorization abstraction layer
gem 'pundit', '~> 0.3.0'

gem 'cancan', '~> 1.6.10'

gem 'icalendar', '~> 2.2.2'

##################################
# Front-end Gems for Rails Admin #
##################################


# Closure Compiler Gem for JS compression
# https://github.com/documentcloud/closure-compiler
gem 'closure-compiler', '~> 1.1.11'

# Oracle adapter
# Purposely excluding this for test environments since folks have to install ojdbc6
group :development, :testext, :production do
  gem 'activerecord-oracle_enhanced-adapter', '~> 1.5.6'
  gem 'rvm-capistrano', '~> 1.3.1'
  gem 'capistrano', '~> 2.15.4'
end

group :development, :test , :testext do
  gem 'rspec-rails', '~> 3.1.0'
  gem 'rspec-mocks', '~> 3.1.3'
  gem 'rspec-support', '~> 3.1.2'
  gem 'rspec-its', '~> 1.1.0'
  gem 'rspec-collection_matchers', '~> 1.1.2'
  gem 'minitest-reporters', '~> 1.0.8'

  # We need to specify the latest webdriver here, to support the latest firefox
  gem 'selenium-webdriver', '~> 2.44.0'

  # Code coverage for Ruby 1.9 with a powerful configuration library and automatic merging of coverage across test suites
  # https://rubygems.org/gems/simplecov
  gem 'simplecov', '~> 0.9.1', require: false

  # Capybara is an integration testing tool for rack based web applications.
  # It simulates how a user would interact with a website
  # https://rubygems.org/gems/capybara
  gem 'capybara', '~> 2.4.4'

  # Headless is a Ruby interface for Xvfb. It allows you to create a headless display straight
  # from Ruby code, hiding some low-level action.
  gem 'headless', '~> 1.0.2'

  # Spork can speed up multiple test runs.
  gem 'spork','1.0.0rc0'
  gem 'guard-spork'
  gem 'spork-rails'

  gem 'webmock', '~> 1.20.4'
end

group :development do
  # Automatically reloads your browser when 'view' files are modified.
  # https://github.com/guard/guard-livereload
  gem 'guard-livereload', '~> 2.4.0', require: false
end

group :test do
  gem 'activerecord-jdbcsqlite3-adapter', '~> 1.3.16'
  gem 'page-object', '~> 1.0.3'
end

group :test, :testext do
  # RSpec results that Hudson + Bamboo + xml happy CI servers can read. See https://rubygems.org/gems/rspec_junit_formatter
  # TODO: Use gem 'rspec_junit_formatter', '~> 0.2.x' when deprecated concern of CLC-3565 is resolved.
  gem 'rspec_junit_formatter', :git => 'https://github.com/sj26/rspec_junit_formatter.git'
end

group :shell_debug do
  gem 'ruby-debug', '>= 0.10.5.rc9'
end

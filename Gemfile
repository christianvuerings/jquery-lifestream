source "https://rubygems.org"

# The core framework
# https://github.com/rails/rails
gem "rails", "3.2.13"

# Postgresql adapter
gem "activerecord-jdbcpostgresql-adapter", "~> 1.2.7"

# H2 adapter
gem "activerecord-jdbch2-adapter", "~> 1.2.7"

# A JSON implementation as a Ruby extension in C
# http://flori.github.com/json/
gem "json", "~> 1.7.7"

# CAS Strategy for OmniAuth
# https://rubygems.org/gems/omniauth-cas
gem "omniauth-cas", "~> 1.0.1"

gem "faraday", "~> 0.8.6"

# OAuth2 support
gem "signet", "~> 0.4.5"
gem "google-api-client", "~> 0.6.2"

# for VCR http recording tool
gem "vcr", "~> 2.4.0"
gem "jruby-openssl", "~> 0.8.4"

# for memcached connection
gem "dalli", "~> 2.6.2"

# smarter logging
gem "log4r", "~> 1.1.10"

# for easier non-DB-backed models
gem "active_attr", "~> 0.7.0"

# for production deployment
gem "trinidad", "~> 1.4.4"
gem "jruby-activemq", "~> 5.5.1"

# Addressable is a replacement for the URI implementation that is part of Ruby's standard library.
# https://github.com/sporkmonger/addressable
gem "addressable", "~> 2.3.3"

# for concurrency management
gem "celluloid", "~> 0.12.4"

# for parsing formatted html
gem 'nokogiri', "~> 1.5.6"

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  # Our very own library for angular dependency!
  gem "angular-gem", "1.1.3"

  # Datepicker
  gem "pikaday-gem", "~> 1.0.0.2"

  # CSS Framework - also includes Compass and SASS
  # https://github.com/zurb/foundation
  gem "sass-rails", "~> 3.2.6"
  gem "coffee-rails", "~> 3.2.1"
  gem "compass-rails", "~> 1.0.3"
  gem "zurb-foundation", "4.0.8"

  # Ruby wrapper for UglifyJS JavaScript compressor
  # https://github.com/lautis/uglifier
  gem "uglifier", "~> 1.3.0"

  # Font awesome - an icon font
  # https://github.com/littlebtc/font-awesome-sass-rails
  gem "font-awesome-sass-rails", "~> 3.0.2.2"

  # Moment.js
  # https://github.com/derekprior/momentjs-rails
  gem "momentjs-rails", "~> 2.0.0.1"

  # Raven.js - library for JS error logging
  gem "ravenjs-gem", "~> 1.0.7.0"
end

# Oracle adapter
# Purposely excluding this for test environments since folks have to install ojdbc6
group :development, :testext, :production do
  gem "activerecord-oracle_enhanced-adapter", "~> 1.4.1"
  gem "rvm-capistrano", "~> 1.2.7"
  gem "capistrano", "~> 2.14.2"
end

group :development, :test , :testext do
  gem "rspec-rails", "~> 2.13.0"
  gem "rspec-mocks", "~> 2.13.0"
  gem "minitest-reporters", "~> 0.14.7"

  # Test our JavaScript code.
  # https://github.com/pivotal/jasmine-gem
  gem "jasmine", "~> 1.3.1"
  gem "jquery-rails", "~> 2.2.1"
  gem "jasmine-jquery-rails", "~> 1.4.2"

  # We need to specify the latest webdriver here, to support the latest firefox
  gem "selenium-webdriver", "~> 2.31.0"

  gem "therubyrhino", "~> 2.0.1"

  # Code coverage for Ruby 1.9 with a powerful configuration library and automatic merging of coverage across test suites
  # https://rubygems.org/gems/simplecov
  gem "simplecov", "~> 0.7.1", require: false

  # Capybara is an integration testing tool for rack based web applications.
  # It simulates how a user would interact with a website
  # https://rubygems.org/gems/capybara
  gem "capybara", "~> 2.0.2"
end

group :development do
  # Automatically reloads your browser when "view" files are modified.
  # https://github.com/guard/guard-livereload
  gem "guard-livereload", "~> 1.1.0"
  gem "rack-livereload", "~> 0.3.11"

  # Polling is evil:
  # https://github.com/guard/guard#readme
  gem "rb-inotify", "~> 0.9.0", require: false
  gem "rb-fsevent", "~> 0.9.2", require: false
  gem "rb-fchange", "~> 0.0.6", require: false

  # Adds extra information to the requests
  # Enables the RailsPanel chrome extension
  gem "meta_request", "~> 0.2.3"
end

group :test do
  gem "activerecord-jdbc-adapter", "~> 1.2.8"
  gem "activerecord-jdbcsqlite3-adapter", "~> 1.2.7"
end

group :test, :testext do
  # RSpec results that Hudson + Bamboo + xml happy CI servers can read.
  # https://rubygems.org/gems/rspec_junit_formatter
  gem "rspec_junit_formatter", "~> 0.1.2"

  gem "webmock", "~> 1.11.0"
end

source "https://rubygems.org"
source 'http://torquebox.org/rubygems'

# The core framework
# https://github.com/rails/rails
gem "rails", "3.2.13"

gem "activerecord-jdbc-adapter", "~> 1.2.9"

# Postgresql adapter
gem "activerecord-jdbcpostgresql-adapter", "~> 1.2.9"

# H2 adapter
gem "activerecord-jdbch2-adapter", "~> 1.2.9"

# A JSON implementation as a Ruby extension in C
# http://flori.github.com/json/
gem "json", "~> 1.8.0"

# CAS Strategy for OmniAuth
# https://rubygems.org/gems/omniauth-cas
gem "omniauth-cas", "~> 1.0.1"

# secure_headers provides x-frame, csp and other http headers
gem "secure_headers", "~> 0.5.0"

gem "faraday", "~> 0.8.7"
gem "faraday_middleware", "~> 0.9.0"

# OAuth2 support
gem "signet", "~> 0.4.5"
gem "google-api-client", "~> 0.6.4"

# for VCR http recording tool
gem "vcr", "~> 2.5.0"
gem "jruby-openssl", "~> 0.8.8"

# for memcached connection
gem "dalli", "~> 2.6.4"

# smarter logging
gem "log4r", "~> 1.1.10"

# for easier non-DB-backed models
gem "active_attr", "~> 0.8.1"

# for production deployment
gem "jruby-activemq", "~> 5.5.1"

# Addressable is a replacement for the URI implementation that is part of Ruby's standard library.
# https://github.com/sporkmonger/addressable
gem "addressable", "~> 2.3.4"

# for concurrency management
gem "celluloid", "~> 0.14.1"

# for parsing formatted html
gem 'nokogiri', "~> 1.5.9"

# for simplified relational data management. rails_admin requires devise.
gem 'rails_admin', "~> 0.4.8"
gem "devise", "~> 2.2.4"

gem "torquebox", "~> 2.3.2"

gem "torquebox-server", "~> 2.3.2"

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  # Our very own library for angular dependency!
  gem "angular-gem", "1.1.5"

  # Datepicker
  gem "pikaday-gem", "~> 1.1.0.0"

  # CSS Framework - also includes Compass and SASS
  # https://github.com/zurb/foundation
  gem "sass-rails", "~> 3.2.6"
  gem "coffee-rails", "~> 3.2.2"
  gem "compass-rails", "~> 1.0.3"
  gem "zurb-foundation", "4.2.1"

  # Ruby wrapper for UglifyJS JavaScript compressor
  # https://github.com/lautis/uglifier
  gem "uglifier", "~> 2.1.1"

  # Font awesome - an icon font
  # https://github.com/littlebtc/font-awesome-sass-rails
  gem "font-awesome-sass-rails", "~> 3.0.2.2"

  # Moment.js
  # https://github.com/derekprior/momentjs-rails
  gem "momentjs-rails", "~> 2.0.0.2"

  # Raven.js - library for JS error logging
  gem "ravenjs-gem", "~> 1.0.7.0"
end

# Oracle adapter
# Purposely excluding this for test environments since folks have to install ojdbc6
group :development, :testext, :production do
  gem "activerecord-oracle_enhanced-adapter", "~> 1.4.1"
  gem "rvm-capistrano", "~> 1.3.1"
  gem "capistrano", "~> 2.15.4"
end

group :development, :test , :testext do
  gem "rspec-rails", "~> 2.13.2"
  gem "rspec-mocks", "~> 2.13.1"
  gem "minitest-reporters", "~> 0.14.20"

  # Test our JavaScript code.
  # https://github.com/pivotal/jasmine-gem
  gem "jasmine", "~> 1.3.1"
  gem "jquery-rails", "~> 2.2.1"
  gem "jasmine-jquery-rails", "~> 1.4.2"

  # We need to specify the latest webdriver here, to support the latest firefox
  gem "selenium-webdriver", "~> 2.32.1"

  gem "therubyrhino", "~> 2.0.1"

  # Code coverage for Ruby 1.9 with a powerful configuration library and automatic merging of coverage across test suites
  # https://rubygems.org/gems/simplecov
  gem "simplecov", "~> 0.7.1", require: false

  # Capybara is an integration testing tool for rack based web applications.
  # It simulates how a user would interact with a website
  # https://rubygems.org/gems/capybara
  gem "capybara", "~> 2.1.0"

  #Headless is a Ruby interface for Xvfb. It allows you to create a headless display straight
  #from Ruby code, hiding some low-level action.
  gem "headless", "~> 1.0.1"
end

group :development do
  # Automatically reloads your browser when "view" files are modified.
  # https://github.com/guard/guard-livereload
  gem "guard-livereload", "~> 1.4.0"
  gem "rack-livereload", "~> 0.3.15"

  # Polling is evil:
  # https://github.com/guard/guard#readme
  gem "rb-inotify", "~> 0.9.0", require: false
  gem "rb-fsevent", "~> 0.9.2", require: false
  gem "rb-fchange", "~> 0.0.6", require: false

  # Adds extra information to the requests
  # Enables the RailsPanel chrome extension
  gem "meta_request", "~> 0.2.6"
end

group :test do
  gem "activerecord-jdbcsqlite3-adapter", "~> 1.2.9"
end

group :test, :testext do
  # RSpec results that Hudson + Bamboo + xml happy CI servers can read.
  # https://rubygems.org/gems/rspec_junit_formatter
  gem "rspec_junit_formatter", "~> 0.1.2"

  gem "webmock", "~> 1.11.0"
end

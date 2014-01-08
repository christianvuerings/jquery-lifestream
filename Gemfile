source "https://rubygems.org"

# The core framework
# https://github.com/rails/rails
gem "rails", "3.2.16"

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
gem "httparty", "~> 0.11.0"

# OAuth2 support
gem "signet", "~> 0.4.5"
gem "google-api-client", "~> 0.6.4"

# LTI support
gem 'ims-lti', :git => "https://github.com/instructure/ims-lti.git"

# for VCR http recording tool
gem "vcr", "~> 2.5.0"

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
gem 'nokogiri', "~> 1.5.9", :platforms => :jruby

# for parsing paged feeds
gem 'link_header', "~> 0.0.7"

# for simplified relational data management. rails_admin requires devise.
gem 'rails_admin', "0.4.9"
gem "devise", "~> 2.2.5"
# rails_admin requires bootstrap_sass but isn't very picky about the version it uses.
# lock bootstrap-sass at 2.3.2.0 because later version introduce an "invalid character" error during assets:precompile
gem "bootstrap-sass", "2.3.2.0"

# TorqueBox app server
gem "torquebox", "~> 3.0.1"
gem "torquebox-server", "~> 3.0.1"
gem "torquebox-messaging", "~> 3.0.1"

# for trying, and trying again, and then giving up.
gem "retriable", "~> 1.3.3.1"

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  # Our very own library for angular dependency!
  gem "angular-gem", "1.2.1"

  # Datepicker
  gem "pikaday-gem", "~> 1.1.0.0"

  # CSS Framework - also includes Compass and SASS
  # https://github.com/zurb/foundation
  gem "sass-rails", "~> 3.2.6"
  gem "coffee-rails", "~> 3.2.2"
  gem "compass-rails", "~> 1.0.3"
  gem "foundation-rails", "~> 5.0.2.0"

  # Closure Compiler Gem for JS compression
  # https://github.com/documentcloud/closure-compiler
  gem "closure-compiler", "~> 1.1.10"

  # Font awesome - an icon font
  # https://github.com/bokmann/font-awesome-rails
  gem "font-awesome-rails", "~> 4.0.0.0"

  # Moment.js
  # https://github.com/derekprior/momentjs-rails
  gem "momentjs-rails", "~> 2.2.1"

  # Placeholder.js
  # https://github.com/ets-berkeley-edu/placeholder-gem
  gem "placeholder-gem", "~> 3.0.0.0"

  # Raven.js - library for JS error logging
  gem "ravenjs-gem", "~> 1.0.7.0"

  # ngmin-rails
  # https://github.com/jasonm/ngmin-rails
  gem "ngmin-rails", "~> 0.4.0"

end

# Oracle adapter
# Purposely excluding this for test environments since folks have to install ojdbc6
group :development, :testext, :production do
  gem "activerecord-oracle_enhanced-adapter", "1.4.2"
  gem "rvm-capistrano", "~> 1.3.1"
  gem "capistrano", "~> 2.15.4"
end

group :development, :test , :testext do
  gem "rspec-rails", "~> 2.13.2"
  gem "rspec-mocks", "~> 2.13.1"
  gem "minitest-reporters", "~> 0.14.20"

  # We need to specify the latest webdriver here, to support the latest firefox
  gem "selenium-webdriver", "~> 2.39.0"

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

  gem "spork", "~> 0.9.2"
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
  gem "meta_request", "~> 0.2.8"
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

group :development, :assets do
  gem "turbo-sprockets-rails3", "~> 0.3.11"
end

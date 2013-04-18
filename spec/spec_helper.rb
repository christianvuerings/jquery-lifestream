ENV["SIMPLE_COV_ENABLED"] ||= "true"
if ENV["SIMPLE_COV_ENABLED"] == "true"
  require 'simplecov'
  SimpleCov.add_filter 'app/views'
  SimpleCov.start 'rails'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'webmock/rspec'
require 'support/spec_helper_module'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Nicer way to hide breaking tests.
  config.filter_run_excluding :ignore => true

  # Exclusion filter: If a test is marked with :testext and true, it will be skipped
  # unless tests were started with the testext environment
  unless ENV["RAILS_ENV"] == 'testext'
    config.filter_run_excluding :testext => true
  end

  # Include Auth helper:
  config.include IntegrationSpecHelper, :type => :feature

  # Clear out cache at the beginning of each test.
  config.before :each do
    Rails.cache.clear
  end

  #Eject casettes after each group of tests.
  config.after :each do
    VCR.eject_cassette
  end

  # Suppress celluloid terminated workers after entire test suite finishes
  config.after :suite do
    Celluloid.logger = nil
  end

  # Include some helper functions for the specs.
  config.include SpecHelperModule
end

Capybara.default_host = 'http://localhost:3000'
OmniAuth.config.test_mode = true
WebMock.enable!
WebMock.allow_net_connect!

# --- Spork Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.

require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.


  ENV["SIMPLE_COV_ENABLED"] ||= "true"
  if ENV["SIMPLE_COV_ENABLED"] == "true"
    require 'simplecov'
    SimpleCov.add_filter 'app/views'
    SimpleCov.add_filter 'vendor/cache'
    SimpleCov.start 'rails'
  end

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'webmock/rspec'

  # create tmp/cache directory if necessary, otherwise the Rails.cache.clear statement before each test may fail
  FileUtils.mkdir_p("tmp/cache") unless File.exists?("tmp/cache")

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # RSpec 3 upgrade: Deprecation warnings will be errors BUT we support deprecated 'should'.
    config.raise_errors_for_deprecations!
    config.infer_spec_type_from_file_location!
    config.mock_with :rspec do |mocks|
      mocks.yield_receiver_to_any_instance_implementation_blocks = false
      mocks.patch_marshal_to_support_partial_doubles = true
    end
    config.expect_with :rspec do |c|
      c.syntax = [:should, :expect]
    end
    config.mock_with :rspec do |c|
      c.syntax = [:should, :expect]
    end

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

    # Make sure the front-end assets are available when running the back-end tests
    if !File.exist?("#{::Rails.root}/public/index-main.html")
      puts 'Front-end build task - spec helper'
      system ("sh #{::Rails.root}/script/front-end-test.sh")
    end

    # Run the UI tests (and only the UI tests) if UI_TEST is present in environment
    if ENV["UI_TEST"]
      config.filter_run_including :testui => true
    else
      config.filter_run_excluding :testui => true
    end

    # Include Auth helper:
    config.include IntegrationSpecHelper, :type => :feature

    # Clear out cache at the beginning of each test.
    config.before :each do
      Rails.cache.clear
    end

    #Reset WebMock after each group of tests.
    config.after :each do
      WebMock.reset!
    end

    # Include some helper functions for the specs.
    config.include SpecHelperModule
  end

  Capybara.default_host = 'http://localhost:3000'
  OmniAuth.config.test_mode = true
  WebMock.enable!

end

Spork.each_run do
  # This code will be run each time you run your specs.

end

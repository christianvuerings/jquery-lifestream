Calcentral::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Enable rack-livereload
  config.middleware.insert_after(ActionDispatch::Static, Rack::LiveReload)

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and enable caching
  config.consider_all_requests_local       = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # We need to leave this to false since otherwise it takes 25 seconds to compile
  # https://jira.media.berkeley.edu/jira/browse/CLC-1585
  config.sass.debug_info = false

  # source maps don't get output if this is true
  config.sass.line_comments = false

  # Caching store
  config.cache_store = ActiveSupport::Cache.lookup_store(:memory_store,
                                                         :size => 16.megabytes,
                                                         :namespace => ServerRuntime.get_settings["git_commit"])
  config.cache_store.logger = Logger.new("#{Rails.root}/log/cache-#{Rails.env}_#{Time.now.strftime('%Y-%m-%d')}.log")
  config.cache_store.logger.level = Logger::DEBUG
end

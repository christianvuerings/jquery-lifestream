# disable restrictions on Java cryptography strength as early as possible, if we're in a Java env that allows it.
begin
  klazz = java.lang.Class.for_name('javax.crypto.JceSecurity')
  field = klazz.get_declared_field('isRestricted')
  if field
    field.tap { |f| f.accessible = true; f.set nil, false }
  end
rescue StandardError
  # Java env does not have isRestricted field, so skip
end

begin
  require 'fcntl'
rescue LoadError
  # Trap a mysterious error loading fcntl. By trapping the error early on, it will give a
  # chance for subsequent libraries that use fcntl to load fcntl properly. Workaround is as
  # suggested at http://markmail.org/message/zukili5zqtvqy7h5
end

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'log4r'
include Log4r
# Let configuration use Rails core extensions like "1.day" and "hash.deep_merge"
require 'active_support/core_ext'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test testext)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Calcentral
  class Application < Rails::Application
    initializer :amend_yaml_config, :before => :load_environment_config do
      # Log4r has the quirk that its logging level constants (referred to
      # by our configuration files) are not available until a Log4r instance
      # has been loaded. We therefore need a bootstrap logger to be able to
      # configure the final logger.
      Rails.logger = Log4r::Logger.new('initial')
      Rails.logger.outputters = Outputter.stdout

      amended_config = CalcentralConfig.load_settings
      Kernel.const_set(:Settings, amended_config)

      # Initialize logging ASAP, rather than waiting for full application initialization.
      CalcentralLogging.init_logging
    end
    initializer :amend_rb_config, :after => :load_environment_config do
      CalcentralConfig.load_ruby_configs
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.eager_load_paths += Dir[Rails.root.join('lib')]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # always be caching
    config.action_controller.perform_caching = true
  end
end

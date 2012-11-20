module Calcentral_settings

  # Hook to append more *.calcentral.yml settings to rails_config, after the
  # rails_config rails hook has fired.
  # See https://github.com/railsjedi/rails_config/blob/master/lib/rails_config/integration/rails.rb
  def append_settings
    # Make sure someone calls this when rails_config has initialized.
    return unless defined?(Settings)

    calcentral_config_dir = ENV["CALCENTRAL_CONFIG_DIR"] unless ENV["CALCENTRAL_CONFIG_DIR"].blank?
    calcentral_config_dir ||= File.expand_path('~/.calcentral_config')

    if (File.exist?(calcentral_config_dir) && File.directory?(calcentral_config_dir))
      # attempt to load additional .calcentral.yml overrides.
      rails_env = ENV["RAILS_ENV"] unless ENV["RAILS_ENV"].blank?
      rails_env ||= "development"

      root_settings = File.join(calcentral_config_dir, "settings.calcentral.yml")
      env_settings = File.join(calcentral_config_dir, "#{rails_env}.calcentral.yml")

      [root_settings, env_settings].each do |file|
        Settings.add_source!(File.path(file)) if (File.exists?(file))
      end
      Settings.reload!
    end
  end
end

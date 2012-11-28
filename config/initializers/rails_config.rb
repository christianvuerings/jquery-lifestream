module RailsConfig
  class << self
    def calcentral_load_and_set(*files)
      files.concat(calcentral_settings)
      standard_load_and_set(files)
    end
    alias standard_load_and_set load_and_set_settings
    alias load_and_set_settings calcentral_load_and_set
    def calcentral_settings
      dir = ENV["CALCENTRAL_CONFIG_DIR"] || File.join(ENV["HOME"], ".calcentral_config")
      if File.exists?(dir)
        dir = File.expand_path(dir)
        [
          File.join(dir, "settings.local.yml"),
          File.join(dir, "#{Rails.env}.local.yml")
        ]
      else
        []
      end
    end
  end
end

RailsConfig.setup do |config|
  config.const_name = "Settings"
end

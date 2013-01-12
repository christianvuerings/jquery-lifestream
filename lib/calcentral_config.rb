module CalcentralConfig
  extend self

  def load_ruby_configs
    calcentral_settings_files("environments", "rb").each do |file|
      if file && File.exists?(file.to_s)
        require file
      end
    end
  end

  def load_settings
    init_logging
    deep_open_struct(load_yaml_settings)
  end

  # We want to configure logging early, but not before Rake tasks start.
  def init_logging
    require 'log4r'
    require 'log4r/outputter/datefileoutputter'
    include Log4r
    app_name = ENV["APP_NAME"] || "calcentral"
    format = PatternFormatter.new(:pattern => "[%d] [%l] [CalCentral] %m")
    Rails.logger = Log4r::Logger.new(app_name)
    stdout = Outputter.stdout
    stdout.formatter = format
    file = case app_name
             when 'calcentral'
               FileOutputter.new('outputter', {
                   filename: "#{Rails.root}/log/#{Rails.env}.log"
               })
             when 'backstage'
               Log4r::DateFileOutputter.new('outputter', {
                   dirname: "#{Rails.root}/log",
                   filename: "backstage.log"
               })
           end
    file.formatter = format
    Rails.logger.outputters = [ stdout, file ]
  end

  def deep_open_struct(hash_recursive)
    require 'ostruct'
    obj = hash_recursive
    if obj.is_a?(Hash)
      obj.each do |key, val|
        obj[key] = deep_open_struct(val)
      end
      obj = OpenStruct.new(obj)
    elsif obj.is_a?(Array)
      obj = obj.map {|val| deep_open_struct(val)}
    end
    obj
  end

  def load_yaml_settings
    loaded_settings = {}
    calcentral_settings_files("settings", "yml").each do |file|
      if file && File.exists?(file.to_s)
        result = YAML.load(ERB.new(IO.read(file.to_s)).result)
        if result
          loaded_settings.deep_merge!(result)
        end
      end
    end
    loaded_settings
  end

  def local_dir
    dir = ENV["CALCENTRAL_CONFIG_DIR"] || File.join(ENV["HOME"], ".calcentral_config")
    File.exists?(dir) ? File.expand_path(dir) : nil
  end

  def calcentral_settings_files(standard_dir, extension)
    files = [
        Rails.root.join("config", "settings.#{extension}"),
        Rails.root.join("config", standard_dir, "#{Rails.env}.#{extension}"),
        Rails.root.join("config", "settings.local.#{extension}"),
        Rails.root.join("config", standard_dir, "#{Rails.env}.local.#{extension}")
    ]
    if local_dir
      files.push(
          File.join(local_dir, "settings.local.#{extension}"),
          File.join(local_dir, "#{Rails.env}.local.#{extension}")
      )
    end
    files
  end
end
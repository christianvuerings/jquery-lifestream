require 'log4r'
require 'log4r/outputter/datefileoutputter'
include Log4r

# monkey-patch Log4r to prevent NoMethodError on startup in rails s.
class Log4r::Logger
  def formatter
  end
end

module CalcentralLogging
  include ClassLogger
  extend self

  def refresh_logging_level
    response = {}
    settings_hash = CalcentralConfig.load_settings
    old_logger_level = Rails.logger.level
    new_logger_level = (settings_hash && settings_hash.logger && settings_hash.logger.level)
    if (!new_logger_level.nil? && new_logger_level != old_logger_level &&
      new_logger_level.is_a?(Integer) &&
      (0...Log4r::LNAMES.length).include?(new_logger_level))
      old_logger_level_name = Log4r::LNAMES[old_logger_level]
      new_logger_level_name = Log4r::LNAMES[new_logger_level]

      Rails.logger.warn "Changing log level from #{old_logger_level_name} to #{new_logger_level_name}"
      Rails.logger.level = new_logger_level
      response = {
        old_logger_level: old_logger_level_name,
        new_logger_level: new_logger_level_name,
      }
    else
      Rails.logger.warn "Unknown, unchanged, or empty new log level (old -> new):"\
        "#{old_logger_level} -> #{new_logger_level}, ignoring."
    end
    response
  end

  def init_logging
    # Set up top-level log4r logger with default log level.
    app_name = ENV["APP_NAME"] || "calcentral"
    Rails.logger = Log4r::Logger.new(app_name)
    Rails.logger.level = Log4r::DEBUG

    config_level = Settings.logger.level
    if config_level.blank?
      config_level = Log4r::INFO
    elsif config_level.is_a?(String)
      config_level = "Log4r::#{config_level}".constantize
    end

    # Set up outputters based on configuration.
    init_stdout(config_level) if Settings.logger.stdout
    init_file_logger(config_level, app_name) if Settings.logger.stdout != 'only'
  end

  def log_root
    ENV["CALCENTRAL_LOG_DIR"] || "#{Rails.root}/log"
  end

  def init_stdout(config_level)
    format = PatternFormatter.new(:pattern => "[%d] [%l] %m")
    stdout = Outputter.stdout
    stdout.formatter = format
    stdout.level = config_level
    Rails.logger.outputters << stdout
  end

  private

  def init_file_logger(config_level, app_name)
    format = PatternFormatter.new(:pattern => "[%d] [%l] [CalCentral] %m")

    filename_suffix = (Rails.env == "production") ? '' : "-#{Rails.env}"

    outputter = Log4r::DateFileOutputter.new('outputter', {
      dirname: CalcentralLogging.log_root,
      filename: "#{app_name}#{filename_suffix}.log",
      formatter: format,
      level: config_level
    })
    Rails.logger.outputters << outputter
  end

end

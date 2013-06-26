require 'log4r'
require 'log4r/outputter/datefileoutputter'
include Log4r

module CalcentralLogging
  extend self

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
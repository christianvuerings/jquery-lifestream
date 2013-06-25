require 'log4r'
require 'log4r/outputter/datefileoutputter'
include Log4r

module CalcentralLogging
  extend self

  def init_logging
    # Set up top-level log4r logger with default log level.
    app_name = ENV["APP_NAME"] || "calcentral"
    Rails.logger = Log4r::Logger.new(app_name)
    Rails.logger.level = DEBUG

    # Set up outputters based on configuration.
    init_stdout if Settings.logger.stdout
    init_file_logger(app_name) if Settings.logger.stdout != 'only'

    # Currently, the file loggers use a hardcoded set of log levels.
    # The configured logger levels therefore only apply to stdout.
    config_level = Settings.logger.level
    if config_level.is_a?(String)
      config_level = "Log4r::#{config_level}".constantize
    end
    std_outputters = Rails.logger.outputters.select {|x| x.is_a?(Log4r::StdoutOutputter)}
    std_outputters.each {|x| x.level = config_level}
  end

  def log_root
    ENV["CALCENTRAL_LOG_DIR"] || "#{Rails.root}/log"
  end

  def init_stdout
    format = PatternFormatter.new(:pattern => "[%d] [%l] %m")
    stdout = Outputter.stdout #controlled by Settings.logger.level
    stdout.formatter = format
    Rails.logger.outputters << stdout
  end

  private

  def init_file_logger(app_name)
    format = PatternFormatter.new(:pattern => "[%d] [%l] [CalCentral] %m")

    filename_suffix = (Rails.env == "production") ? '' : "-#{Rails.env}"

    outputter = Log4r::DateFileOutputter.new('outputter', {
      dirname: CalcentralLogging.log_root,
      filename: "#{app_name}#{filename_suffix}.log",
      formatter: format,
      level: Settings.logger.level,
    })
    Rails.logger.outputters << outputter
  end

end
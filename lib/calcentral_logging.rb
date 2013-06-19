require 'log4r'
require 'log4r/outputter/datefileoutputter'
include Log4r

module CalcentralLogging
  extend self
  # We want to configure logging early, but not before Rake tasks start.
  def init_logging
    app_name = ENV["APP_NAME"] || "calcentral"
    format = PatternFormatter.new(:pattern => "[%d] [%l] [CalCentral] %m")

    Rails.logger = Log4r::Logger.new(app_name)
    Rails.logger.level = DEBUG
    Rails.logger.outputters = init_file_loggers(app_name, format)
  end

  def log_root
    ENV["CALCENTRAL_LOG_DIR"] || "#{Rails.root}/log"
  end

  private

  def init_file_loggers(app_name, format)
    logger_levels = Log4r::LNAMES.dup - ["ALL", "OFF"]
    logger_levels.map do |level|
      filename_suffix = (Rails.env == "production") ? '' : "-#{Rails.env}"
      filename_suffix += "-#{level}"

      Log4r::DateFileOutputter.new('outputter', {
        dirname: CalcentralLogging.log_root,
        filename: "#{app_name}#{filename_suffix}.log",
        formatter: format,
        level: Object.const_get("#{level}")
      })
    end
  end

end
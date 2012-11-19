Rails.application.config.after_initialize do
  Rails.logger.level = Settings.logger.level
end

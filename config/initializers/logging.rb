Rails.application.config.after_initialize do
  std_outputters = Rails.logger.outputters.select {|x| x.is_a?(Log4r::StdoutOutputter)}
  std_outputters.each {|x| x.level = Settings.logger.level}
end

Rails.application.config.after_initialize do
  if Settings.logger.stdout
    CalcentralLogging.init_stdout
  end
  std_outputters = Rails.logger.outputters.select {|x| x.is_a?(Log4r::StdoutOutputter)}
  std_outputters.each {|x| x.level = Settings.logger.level}
end

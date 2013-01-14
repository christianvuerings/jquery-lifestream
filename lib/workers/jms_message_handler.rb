class JmsMessageHandler
  include Celluloid

  def handle(message)
    Rails.logger.info "#{Thread.current} is now reading #{message}"
  end

  def finalize
    Rails.logger.debug "JmsMessageHandler on thread #{Thread.current} is going away"
  end

end
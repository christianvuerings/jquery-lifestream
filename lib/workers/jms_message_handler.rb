class JmsMessageHandler
  include Celluloid

  finalizer :log_terminate

  def initialize(processors = [RegStatusEventProcessor.new, FinalGradesEventProcessor.new])
    @processors = processors
  end

  def handle(message)
    Rails.logger.info "#{Thread.current} is now reading #{message}"
    if message[:text]
      message_data = JSON.parse message[:text]
      Rails.logger.info "message_data = #{message_data}"
      if message_data['eventNotification'] && message_data['eventNotification']['event']
        @processors.each do |processor|
          processor.process(message_data['eventNotification']["event"], message[:timestamp])
        end
      else
        Rails.logger.info "#{Thread.current} JMS message has text but no eventNotification => event, skipping"
      end
    else
      Rails.logger.info "#{Thread.current} JMS message has no text, skipping"
    end
  rescue JSON::ParserError => e
    Rails.logger.warn "#{Thread.current} Skipping JMS message that has invalid JSON: #{e}"
  end

  def log_terminate
    Rails.logger.debug "JmsMessageHandler on thread #{Thread.current} is going away"
  end

end

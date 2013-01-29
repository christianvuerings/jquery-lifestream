class JmsMessageHandler
  include Celluloid

  def initialize(processors = [RegStatusEventProcessor.new, FinalGradesEventProcessor.new])
    @processors = processors
  end

  def handle(message)
    Rails.logger.info "#{Thread.current} is now reading #{message}"
    if message[:text]
      message_data = JSON.parse message[:text]
      Rails.logger.info "message_data = #{message_data}"
      if message_data["event"]
        @processors.each do |processor|
          processor.process(message_data["event"], message[:timestamp])
        end
      else
        Rails.logger.info "#{Thread.current} JMS message has text but no event, skipping"
      end
    else
      Rails.logger.info "#{Thread.current} JMS message has no text, skipping"
    end
  end

  def finalize
    Rails.logger.debug "JmsMessageHandler on thread #{Thread.current} is going away"
  end

end

class JmsMessageHandler

  def initialize(processors = [RegStatusEventProcessor.new, FinalGradesEventProcessor.new])
    @processors = processors
  end

  def handle(message)
    Rails.logger.warn "#{self.class.name} #{Thread.current} Raw message_data = #{message}"
    if message[:text]
      message_data = JSON.parse message[:text]
      if message_data['eventNotification'] && message_data['eventNotification']['event']
        begin
          if message_data['eventNotification']["event"]["timestamp"]
            timestamp = DateTime.parse(message_data['eventNotification']["event"]["timestamp"])
          else
            timestamp = Time.now.to_datetime
          end
        rescue ArgumentError => e
          timestamp = Time.now.to_datetime
        end
        @processors.each do |processor|
          processor.process(message_data['eventNotification']["event"], timestamp)
        end
      else
        Rails.logger.warn "#{self.class.name} #{Thread.current} JMS message has text but no eventNotification => event, skipping"
      end
    else
      Rails.logger.warn "#{self.class.name} #{Thread.current} JMS message has no text, skipping"
    end
  rescue JSON::ParserError => e
    Rails.logger.error "#{self.class.name} #{Thread.current} Skipping JMS message that has invalid JSON: #{e}"
  end

end

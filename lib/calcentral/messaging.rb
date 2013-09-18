module Calcentral

  class Messaging

    def self.publish(queue_name, message = {})
      queue = self.get_queue queue_name
      if queue.respond_to? :publish
        begin
          # TODO add enabled flag for torquebox messaging, send dummy message in log if disabled
          # queue.publish message
          Rails.logger.debug "TorqueBox queue #{queue_name} is enabled, sending message content: #{message}"
        rescue javax.jms.JMSException
          Rails.logger.warn "Could not publish to TorqueBox Messaging Queue: #{queue_name}"
          @queues[name] = false
        end
      else
        Rails.logger.debug "TorqueBox queue #{queue_name} is disabled, not really sending message. Message content: #{message}"
      end
    end

    private

    def self.get_queue(name)
      @queues ||= {}
      begin
        @queues[name] ||= TorqueBox::Messaging::Queue.new(name)
      rescue javax.jms.JMSException
        Rails.logger.warn "Could not initialize TorqueBox Messaging Queue: #{name}"
        @queues[name] = false
      end
      @queues[name]
    end

  end

end

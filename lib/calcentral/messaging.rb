module Calcentral

  class Messaging

    include ClassLogger

    def self.publish(queue_name, message = {})
      unless Settings.messaging.enabled
        logger.debug "TorqueBox messaging is disabled, not really sending message. Queue: #{queue_name}. Message content: #{message}"
        return
      end
      queue = self.get_queue queue_name
      logger.debug "TorqueBox queue #{queue_name} is enabled, sending message content: #{message}"
      queue.publish message
    end

    private

    def self.get_queue(name)
      @queues ||= {}
      @queues[name] ||= TorqueBox::Messaging::Queue.new(name)
    end

  end

end

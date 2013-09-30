module Calcentral

  class Messaging

    include ClassLogger

    def self.publish(queue_name, message = {})
      unless Settings.messaging.enabled
        logger.debug "#{queue_name} disabled, not really sending message: #{message}"
        return
      end
      queue = self.get_queue queue_name
      logger.debug "#{queue_name} enabled, sending message: #{message}"
      queue.publish message
    end

    private

    def self.get_queue(name)
      @queues ||= {}
      @queues[name] ||= TorqueBox::Messaging::Queue.new(name)
    end

  end

end

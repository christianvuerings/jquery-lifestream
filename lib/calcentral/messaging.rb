module Calcentral

  class Messaging

    include ClassLogger

    def self.publish(queue_name, message = {}, options = {ttl: 120000, persistent: false})
      if $rails_rake_task || !Settings.messaging.enabled
        logger.warn "#{queue_name} disabled, not really sending message: #{message}"
        return
      end
      queue = self.get_queue queue_name
      logger.warn "#{queue_name} sending message: #{message}"
      queue.publish(message, options)
    end

    private

    def self.get_queue(name)
      @queues ||= {}
      @queues[name] ||= TorqueBox::Messaging::Queue.new(name)
    end

  end

end

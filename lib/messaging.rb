class Messaging

  include ClassLogger

  def self.publish(destination_name, message = {}, options = {ttl: 120000, persistent: false})
    unless ENV['IS_TORQUEBOX']
      logger.warn "TorqueBox not running, #{destination_name} disabled, not really sending message: #{message}"
      return
    end
    destination = destination_name.start_with?('/queues/') ?
      self.get_queue(destination_name) :
      self.get_topic(destination_name)
    logger.warn "#{destination_name} sending message: #{message}"
    destination.publish(message, options)
  end

  private

  def self.get_queue(name)
    @queues ||= {}
    @queues[name] ||= TorqueBox::Messaging::Queue.new(name)
  end

  def self.get_topic(name)
    @topics ||= {}
    @topics[name] ||= TorqueBox::Messaging::Topic.new(name)
  end

end

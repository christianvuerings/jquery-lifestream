Rails.application.config.after_initialize do
  begin
    # send a message to warm up the message queues on app start
    queue = TorqueBox::Messaging::Queue.new('/queues/warmup_request')
    queue.publish ""
  rescue javax.jms.JMSException
    Rails.logger.warn "Could not initialize TorqueBox Messaging Queue"
  end
end


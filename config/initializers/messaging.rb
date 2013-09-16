Rails.application.config.after_initialize do
  # send a message to warm up the message queues on app start
  queue = TorqueBox::Messaging::Queue.new('/queues/warmup_request')
  queue.publish ""
end


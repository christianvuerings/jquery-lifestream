Rails.application.config.after_initialize do
  queue = TorqueBox::Messaging::Queue.new('/queues/warmup_request')
  queue.publish "bogus uid just to warm up the message queues"
end


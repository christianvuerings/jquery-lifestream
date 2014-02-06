Rails.application.config.after_initialize do
  # send a message to warm up the message queues on app start
  Calcentral::Messaging.publish('/queues/hot_plate')
  Calcentral::Messaging.publish('/queues/warmup_request')
  Calcentral::Messaging.publish('/queues/feed_changed')
  Calcentral::Messaging.publish('/queues/delayed_cache_cleaner')
end

class DelayedCacheCleaner < TorqueBox::Messaging::MessageProcessor

  include ClassLogger

  def on_message(body)
    cache_key = body["cache_key"]
    if cache_key.present?
      Thread.new {
        sleep body["delay"]
        logger.debug "Handling cache deletion for key: #{cache_key}"
        Rails.cache.delete(cache_key, :force => true)
      }
    end
  end

  def on_error(exception)
    logger.error "Got an exception handling a message: #{exception.inspect}"
    raise exception
  end

  def self.queue(cache_key, delay_seconds = 2)
    if cache_key.present?
      logger.debug "Queueing up cache deletion for key: #{cache_key}"
      Calcentral::Messaging.publish('/queues/delayed_cache_cleaner', {
        "cache_key" => cache_key,
        "delay" => delay_seconds
      })
      return true
    end
    nil
  end

end

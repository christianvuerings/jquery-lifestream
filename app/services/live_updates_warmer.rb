class LiveUpdatesWarmer < TorqueBox::Messaging::MessageProcessor

  extend Calcentral::Cacheable, Calcentral::StatAccumulator
  include ActiveRecordHelper, ClassLogger
  attr_reader :total_warmups

  def self.total_warmups_requested
    "#{self.name} Total Warmups Requested"
  end

  def self.total_warmup_time
    "#{self.name} Total Warmup Time"
  end

  def self.ping
    warmup_count = self.report self.total_warmups_requested
    time = self.report self.total_warmup_time
    if warmup_count || time
      "#{warmup_count} #{time}"
    else
      "#{self.name} Stats are not available, LiveUpdatesWarmer may not have run yet"
    end
  end

  def self.warmup_request(uid)
    Rails.cache.fetch("LiveUpdatesWarmer/WarmupRequestRateLimiter-#{uid}", :expires_in => self.expires_in) do
      Calcentral::Messaging.publish('/queues/warmup_request', uid)
      true
    end
  end

  def on_message(body)
    warmup_merged_feeds body unless body.blank?
  end

  def on_error(exception)
    logger.error "Got an exception handling a message: #{exception.inspect}"
    raise exception
  end

  def warmup_merged_feeds(uid)
    start_time = Time.now.to_i
    logger.warn "Processing warmup_request message for uid #{uid}"
    Calcentral::MERGED_FEEDS_EXPIRATION.notify uid
    begin
      UserCacheWarmer.do_warm uid
    rescue Exception => e
      logger.error "#{self.class.name} Got exception while warming cache for user #{uid}: #{e}. Backtrace: #{e.backtrace.join("\n")}"
    ensure
      ActiveRecordHelper.clear_active_connections
      ActiveRecordHelper.clear_stale_connections
    end
    end_time = Time.now.to_i
    time = end_time - start_time
    self.class.increment(self.class.total_warmup_time, time)
    self.class.increment(self.class.total_warmups_requested, 1)
  end

end


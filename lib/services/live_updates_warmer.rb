# Refreshes user-specific cached data and keeps track of stats showing how long it took.
# Warmup happens asynchronously in the TorqueBox messaging queue so that load can be shared
# among all machines in the cluster.
class LiveUpdatesWarmer < TorqueBox::Messaging::MessageProcessor

  extend Cache::Cacheable, Cache::StatAccumulator
  include ActiveRecordHelper, ClassLogger
  attr_reader :total_warmups

  def self.total_warmups_requested
    "#{self.name} Total Warmups Requested"
  end

  def self.total_warmup_time
    "#{self.name} Total Warmup Time"
  end

  def self.ping
    warmup_count = self.get_value(self.total_warmups_requested)
    time = self.get_value(self.total_warmup_time)
    if warmup_count || time
      {
        total_warmups_requested: warmup_count,
        total_warmup_time: time
      }
    else
      "#{self.name} Stats are not available, LiveUpdatesWarmer may not have run yet"
    end
  end

  def self.warmup_request(uid)
    Rails.cache.fetch("LiveUpdatesWarmer/WarmupRequestRateLimiter-#{uid}", :expires_in => self.expires_in) do
      Messaging.publish('/queues/warmup_request', uid)
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
    begin
      Cache::UserCacheWarmer.do_warm uid
    rescue => e
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


class HotPlate < TorqueBox::Messaging::MessageProcessor

  extend Calcentral::Cacheable, Calcentral::StatAccumulator
  include ActiveRecordHelper, ClassLogger
  attr_reader :total_warmups

  TOTAL_WARMUPS_REQUESTED = "Total Warmups Requested"
  TOTAL_WARMUP_TIME = "Total Warmup Time"

  def run
    if Settings.hot_plate.enabled
      warm
    else
      logger.warn "#{self.class.name} is disabled, skipping warmup"
    end
  end

  def self.ping
    warmup_count = self.report TOTAL_WARMUPS_REQUESTED
    time = self.report TOTAL_WARMUP_TIME
    if warmup_count || time
      "#{self.name} #{warmup_count} #{time}"
    else
      "#{self.name} Stats are not available, HotPlate may not have run yet"
    end
  end

  def self.warmup_request(uid)
    Rails.cache.fetch("HotPlate/WarmupRequestRateLimiter-#{uid}", :expires_in => self.expires_in) do
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

  def warm
    begin
      use_pooled_connection {
        today = Time.zone.today.to_time_in_current_zone.to_datetime
        cutoff = today.advance(:seconds => -1 * Settings.hot_plate.last_visit_cutoff)
        purge_cutoff = today.advance(:seconds => -1 * 2 * Settings.hot_plate.last_visit_cutoff)

        visits = UserVisit.where("last_visit_at >= :cutoff", :cutoff => cutoff.to_date)
        logger.warn "#{self.class.name} Starting to warm up #{visits.size} users; cutoff date #{cutoff}"

        visits.find_in_batches do |batch|
          batch.each do |visit|
            self.class.warmup_request visit.uid
          end
        end

        visits = UserVisit.where("last_visit_at < :cutoff", :cutoff => purge_cutoff.to_date)
        deleted_count = 0
        visits.find_in_batches do |batch|
          batch.each do |visit|
            Calcentral::USER_CACHE_EXPIRATION.notify visit.uid
            visit.delete
            deleted_count += 1
          end
        end
        logger.warn "#{self.class.name} Purged #{deleted_count} users who have not visited since twice the cutoff interval; date #{purge_cutoff}"
      }

    ensure
      ActiveRecordHelper.clear_active_connections
      ActiveRecordHelper.clear_stale_connections
    end

  end

  def expire_then_complete_warmup(uid)
    Calcentral::USER_CACHE_EXPIRATION.notify uid
    begin
      UserCacheWarmer.do_warm uid
    rescue Exception => e
      logger.error "#{self.class.name} Got exception while warming cache for user #{uid}: #{e}. Backtrace: #{e.backtrace.join("\n")}"
    end
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
    self.class.increment(TOTAL_WARMUP_TIME, time)
    self.class.increment(TOTAL_WARMUPS_REQUESTED, 1)
  end

end


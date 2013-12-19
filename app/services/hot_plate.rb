class HotPlate < TorqueBox::Messaging::MessageProcessor

  extend Calcentral::Cacheable, Calcentral::StatAccumulator
  include ActiveRecordHelper, ClassLogger
  attr_reader :total_warmups

  def self.total_warmups_processed
    "#{self.name} Total Warmups Processed"
  end

  def self.total_warmups_requested
    "#{self.name} Total Warmups Requested"
  end

  def self.total_warmup_time
    "#{self.name} Total Warmup Time"
  end

  def run
    if Settings.hot_plate.enabled
      warm
    else
      logger.warn "#{self.class.name} is disabled, skipping warmup"
    end
  end

  def self.ping
    request_count = self.report self.total_warmups_requested
    processed_count = self.report self.total_warmups_processed
    time = self.report self.total_warmup_time
    if request_count || processed_count || time
      "#{self.name}: #{request_count}; #{processed_count}; #{time}"
    else
      "#{self.name} Stats are not available, HotPlate may not have run yet"
    end
  end

  def on_message(body)
    expire_then_complete_warmup body unless body.blank?
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
        self.class.increment(self.class.total_warmups_requested, visits.size)

        visits.find_in_batches do |batch|
          batch.each do |visit|
            Calcentral::Messaging.publish('/queues/hot_plate', visit.uid, {ttl: 86400000, persistent: false})
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
    start_time = Time.now.to_i
    logger.warn "Doing complete feed warmup for uid #{uid}"
    self.class.increment(self.class.total_warmups_processed, 1)
    Calcentral::USER_CACHE_EXPIRATION.notify uid
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
  end

end


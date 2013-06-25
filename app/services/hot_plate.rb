class HotPlate

  include ActiveRecordHelper
  attr_reader :total_warmups

  MUTEX = Mutex.new

  def initialize
    MUTEX.synchronize do
      @total_warmups = 0
      @total_time = 0
      @last_warmup = ''
      @stopped = false
    end
  end

  def start
    if Settings.hot_plate.enabled
      Thread.new { run }
    else
      Rails.logger.info "#{self.class.name} is disabled, not starting thread"
    end
  end

  def stop
    @stopped = true
  end

  def run
    sleep Settings.hot_plate.startup_delay
    until @stopped do
      Rails.logger.debug "#{self.class.name} waking up to warm user caches"
      warm
      sleep Settings.hot_plate.warmup_interval
    end
  end

  def ping
    MUTEX.synchronize do
      "#{self.class.name} #{@total_warmups} total warmups requested; #{@total_time}s total spent warming; last warmup at #{@last_warmup.to_s}"
    end
  end

  def warm
    begin
      start_time = Time.now.to_f
      use_pooled_connection {
        today = Time.zone.today.to_time_in_current_zone.to_datetime
        cutoff = today.advance(:seconds => -1 * Settings.hot_plate.last_visit_cutoff)
        purge_cutoff = today.advance(:seconds => -1 * 2 * Settings.hot_plate.last_visit_cutoff)
        warmups = 0

        visits = UserVisit.where("last_visit_at >= :cutoff", :cutoff => cutoff.to_date)
        Rails.logger.info "#{self.class.name} Starting to warm up #{visits.size} users; cutoff date #{cutoff}"

        visits.find_in_batches do |batch|
          batch.each do |visit|
            Calcentral::USER_CACHE_EXPIRATION.notify visit.uid
            begin
              UserCacheWarmer.do_warm visit.uid
              warmups += 1
            rescue Exception => e
              Rails.logger.error "#{self.class.name} Got exception while warming cache for user #{visit.uid}: #{e}. Backtrace: #{e.backtrace.join("\n")}"
            end
          end
        end

        end_time = Time.now.to_f
        time = end_time - start_time
        MUTEX.synchronize do
          @total_warmups += warmups
          @total_time += time
          @last_warmup = Time.zone.now
        end
        Rails.logger.info "#{self.class.name} Warmed up #{visits.size} users in #{time}s; cutoff date #{cutoff}"

        visits = UserVisit.where("last_visit_at < :cutoff", :cutoff => purge_cutoff.to_date)
        deleted_count = 0
        visits.find_in_batches do |batch|
          batch.each do |visit|
            Calcentral::USER_CACHE_EXPIRATION.notify visit.uid
            visit.delete
            deleted_count += 1
          end
        end
        Rails.logger.info "#{self.class.name} Purged #{deleted_count} users who have not visited since twice the cutoff interval; date #{purge_cutoff}"
      }

    ensure
      ActiveRecord::Base.clear_active_connections!
    end

  end

end


class HotPlate

  include ActiveRecordHelper
  attr_reader :total_warmups

  def initialize
    @total_warmups = 0
    @total_time = 0
    @stopped = false
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
    "#{self.class.name} #{Thread.list.size} threads; #{Celluloid::Actor.all.count} actors; #{@total_warmups} total warmups requested; #{@total_time}s total spent warming"
  end

  def warm
    begin
      start_time = Time.now.to_f
      use_pooled_connection {
        today = Time.zone.today.to_time_in_current_zone.to_datetime
        cutoff = today.advance(:seconds => -1 * Settings.hot_plate.last_visit_cutoff)
        purge_cutoff = today.advance(:seconds => -1 * 2 * Settings.hot_plate.last_visit_cutoff)

        visits = UserVisit.where("last_visit_at >= :cutoff", :cutoff => cutoff.to_date)
        Rails.logger.info "#{self.class.name} Starting to warm up #{visits.size} users; cutoff date #{cutoff}"

        visits.find_in_batches do |batch|
          batch.each do |visit|
            Calcentral::USER_CACHE_EXPIRATION.notify visit.uid
            begin
              UserCacheWarmer.do_warm visit.uid
              @total_warmups += 1
            rescue Exception => e
              Rails.logger.error "#{self.class.name} Got exception while warming cache for user #{visit.uid}: #{e}. Backtrace: #{e.backtrace.join("\n")}"
            end
          end
        end

        end_time = Time.now.to_f
        time = end_time - start_time
        @total_time += time
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
      Rails.logger.debug "Clearing connections for thread and other dead threads after cache warming: #{self.object_id}"
      ActiveRecord::Base.clear_active_connections!
    end

  end

end


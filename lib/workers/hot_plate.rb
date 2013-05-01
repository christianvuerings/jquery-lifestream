class HotPlate

  include Celluloid

  def run
    sleep Settings.hot_plate.startup_delay
    while true do
      Rails.logger.debug "#{self.class.name} waking up to warm user caches"
      warm
      sleep Settings.hot_plate.warmup_interval
    end
  end

  def ping
    "#{self.class.name} #{Thread.list.size} threads; #{Celluloid::Actor.all.count} actors"
  end

  def warm
    today = Time.zone.today.to_time_in_current_zone.to_datetime
    cutoff = today.advance(:seconds => -1 * Settings.hot_plate.last_visit_cutoff)
    purge_cutoff = today.advance(:seconds => -1 * 2 * Settings.hot_plate.last_visit_cutoff)

    visits = UserVisit.where("last_visit_at >= :cutoff", :cutoff => cutoff.to_date)
    visits.find_in_batches do |batch|
      batch.each do |visit|
        Calcentral::USER_CACHE_EXPIRATION.notify visit.uid
        Calcentral::USER_CACHE_WARMER.warm visit.uid
      end
    end
    Rails.logger.info "#{self.class.name} Warmed #{visits.size} users who have visited since cutoff interval; date #{cutoff}"

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

  end

end

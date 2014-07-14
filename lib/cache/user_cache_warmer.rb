module Cache
  class UserCacheWarmer

    def self.do_warm(uid)
      force_cache_write = true
      Rails.logger.debug "#{self.name} Warming the user cache for #{uid}"
      Cache::LiveUpdatesEnabled.classes.each do |klass|
        model = klass.new uid
        model.get_feed_as_json force_cache_write
      end
      Rails.logger.debug "#{self.name} Finished warming the user cache for #{uid}"
    end

  end
end

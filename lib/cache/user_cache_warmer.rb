module Cache
  class UserCacheWarmer

    def self.do_warm(uid)
      Rails.logger.debug "#{self.name} Warming the user cache for #{uid}"
      Cache::LiveUpdatesEnabled.classes.each do |klass|
        model = klass.new uid
        model.warm_cache
      end
      Rails.logger.debug "#{self.name} Finished warming the user cache for #{uid}"
    end

  end
end

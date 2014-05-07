require 'observer.rb'


module Calcentral

  Rails.application.config.after_initialize do

    USER_CACHE_WARMER = Cache::UserCacheWarmer.new

    USER_CACHE_EXPIRATION = Cache::UserCacheInvalidator.new

    (Cache::UserCacheExpiry.classes + Cache::LiveUpdatesEnabled.classes).each do |klass|
      USER_CACHE_EXPIRATION.add_observer(klass, :expire)
    end

    #Pseudo-prefix constant
    PSEUDO_USER_PREFIX = "pseudo_"

  end
end


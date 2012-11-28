require 'observer.rb'

module Calcentral

  class UserCacheInvalidator

    include Observable

    def notify(uid)
      Rails.logger.debug "Expiring user cache for uid #{uid}; Observers: #@observer_peers"
      changed
      notify_observers(uid)
    end
  end

  USER_CACHE_EXPIRATION = Calcentral::UserCacheInvalidator.new

  {
      UserApi => :expire,
      UserApiController => :expire,
      MyCourseSites => :expire
  }.each do |key, value|
    USER_CACHE_EXPIRATION.add_observer(key, value)
  end

end


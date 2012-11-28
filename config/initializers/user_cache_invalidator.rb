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
  USER_CACHE_EXPIRATION.add_observer(UserApi, :expire)
  USER_CACHE_EXPIRATION.add_observer(UserApiController, :expire)
  USER_CACHE_EXPIRATION.add_observer(MyCourseSites, :expire)

end


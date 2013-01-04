require 'observer.rb'

class UserCacheInvalidator

  include Observable

  def notify(uid)
    Rails.logger.debug "#{self.class.name} Expiring user cache for uid #{uid}; Observers: #@observer_peers"
    changed
    notify_observers(uid)
  end

end


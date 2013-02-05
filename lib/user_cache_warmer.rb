require 'celluloid'

class UserCacheWarmer

  def initialize
    @pool = WarmingWorker.pool(size: 6)
  end

  def warm(uid)
    @pool.warm!(uid) # bang suffix means call the warm method asynchronously
  end

  class WarmingWorker
    include Celluloid

    # hit the methods of merged models that serve cacheable pages to users.
    # this will warm up the cache for those pages.

    def warm(uid)
      Rails.logger.info "#{self.class.name} Warming the user cache for #{uid}"
      [
          UserApi.new(uid),
          MyClasses.new(uid),
          MyGroups.new(uid),
          MyTasks::Merged.new(uid),
          MyUpNext.new(uid),
          MyNotifications.new(uid)
      ].each do |model|
        model.get_feed
      end
      Rails.logger.info "#{self.class.name} Finished warming the user cache for #{uid}"
    end
  end
end


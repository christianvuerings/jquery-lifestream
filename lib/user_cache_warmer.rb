class UserCacheWarmer

  def initialize(uid)
    @uid = uid
  end

  def warm
    # hit the methods of merged models that serve cacheable pages to users.
    # this will warm up the cache for those pages.

    Rails.logger.info "Warming the user cache for #@uid"

    [
        UserApi.new(@uid),
        MyClasses.new(@uid),
        MyGroups.new(@uid),
        MyTasks.new(@uid),
        MyUpNext.new(@uid)
    ].each do |model|
      model.get_feed
    end

    Rails.logger.info "Finished warming the user cache for #@uid"

  end

end


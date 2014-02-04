class UserCacheWarmer

  def self.do_warm(uid)
    force_cache_write = true
    Rails.logger.debug "#{self.name} Warming the user cache for #{uid}"
    [
      UserApi.new(uid),
      MyClasses::Merged.new(uid),
      MyFinancials.new(uid),
      MyGroups::Merged.new(uid),
      MyTasks::Merged.new(uid),
      MyBadges::Merged.new(uid),
      MyUpNext.new(uid),
      MyActivities::Merged.new(uid),
      MyAcademics::Merged.new(uid),
      MyRegBlocks.new(uid)
    ].each do |model|
      model.get_feed force_cache_write
      model.get_feed_as_json force_cache_write
    end
    Rails.logger.debug "#{self.name} Finished warming the user cache for #{uid}"
  end

end

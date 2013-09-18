require 'celluloid'

class UserCacheWarmer

  def self.do_warm(uid)
    Rails.logger.debug "#{self.name} Warming the user cache for #{uid}"
    [
      UserApi.new(uid),
      MyClasses.new(uid),
      MyGroups.new(uid),
      MyTasks::Merged.new(uid),
      MyBadges::Merged.new(uid),
      MyUpNext.new(uid),
      MyActivities::Merged.new(uid),
      MyAcademics::Merged.new(uid),
      MyRegBlocks.new(uid),
      CanvasUserSites.new(uid)
    ].each do |model|
      model.get_feed
    end
    Rails.logger.debug "#{self.name} Finished warming the user cache for #{uid}"
  end

end


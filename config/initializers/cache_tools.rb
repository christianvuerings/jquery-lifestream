require 'observer.rb'

module Calcentral

  Rails.application.config.after_initialize do

    USER_CACHE_WARMER = UserCacheWarmer.new

    USER_CACHE_EXPIRATION = Calcentral::UserCacheInvalidator.new

    {
        UserApi => :expire,
        MyClasses => :expire,
        MyTasks => :expire,
        MyUpNext => :expire,
        MyGroups => :expire,

        CanvasProxy => :expire,
        CanvasComingUpProxy => :expire,
        CanvasCoursesProxy => :expire,
        CanvasGroupsProxy => :expire,
        CanvasTodoProxy => :expire,

        GoogleProxy => :expire,
        GoogleCreateTaskListProxy => :expire,
        GoogleDeleteTaskListProxy => :expire,
        GoogleEventsListProxy => :expire,
        GoogleInsertTaskProxy => :expire,
        GoogleTasksListProxy => :expire,
        GoogleUpdateTaskProxy => :expire,

        SakaiProxy => :expire,
        SakaiCategorizedProxy => :expire,
        SakaiUnreadProxy => :expire

    }.each do |key, value|
      USER_CACHE_EXPIRATION.add_observer(key, value)
    end

  end
end


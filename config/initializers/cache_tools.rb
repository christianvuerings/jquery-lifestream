require 'observer.rb'


module Calcentral

  Rails.application.config.after_initialize do

    USER_CACHE_WARMER = UserCacheWarmer.new

    USER_CACHE_EXPIRATION = UserCacheInvalidator.new

    {
        UserApi => :expire,
        MyClasses => :expire,
        MyTasks::Merged => :expire,
        MyBadges::Merged => :expire,
        MyUpNext => :expire,
        MyGroups => :expire,
        MyActivities => :expire,
        MyAcademics::Merged => :expire,

        BearfactsExamsProxy => :expire,
        BearfactsProfileProxy => :expire,
        BearfactsRegblocksProxy => :expire,
        BearfactsScheduleProxy => :expire,

        CalLinkMembershipsProxy => :expire,

        CampusUserCoursesProxy => :expire,

        CanvasProxy => :expire,
        CanvasComingUpProxy => :expire,
        CanvasCoursesProxy => :expire,
        CanvasGroupsProxy => :expire,
        CanvasTodoProxy => :expire,
        CanvasUserActivityProxy => :expire,
        CanvasUserActivityProcessor => :expire,
        CanvasUserProfileProxy => :expire,

        MyBadges::GoogleCalendar => :expire,
        MyBadges::GoogleDrive => :expire,
        MyBadges::GoogleMail => :expire,
        MyTasks::GoogleTasks => :expire,

        SakaiProxy => :expire,
        SakaiUserSitesProxy => :expire

    }.each do |key, value|
      USER_CACHE_EXPIRATION.add_observer(key, value)
    end

    #Pseudo-prefix constant
    PSEUDO_USER_PREFIX = "pseudo_"

  end
end


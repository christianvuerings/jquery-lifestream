require 'observer.rb'


module Calcentral

  Rails.application.config.after_initialize do

    USER_CACHE_WARMER = UserCacheWarmer.new

    USER_CACHE_EXPIRATION = UserCacheInvalidator.new
    MERGED_FEEDS_EXPIRATION = UserCacheInvalidator.new

    {
      MyRegBlocks => :expire,
      CalLinkMembershipsProxy => :expire,

      CampusUserCoursesProxy => :expire,

      CanvasProxy => :expire,
      CanvasUserCoursesProxy => :expire,
      CanvasGroupsProxy => :expire,
      CanvasTodoProxy => :expire,
      CanvasUpcomingEventsProxy => :expire,
      CanvasUserActivityStreamProxy => :expire,
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

    merged_feeds_array = [
      UserApi,
      MyClasses,
      MyGroups,
      MyActivities::Merged,
      MyTasks::Merged,
      MyBadges::Merged,
      MyUpNext,
      CanvasUserSites,
      MyRegBlocks
    ]
    MERGED_FEEDS = {}
    merged_feeds_array.each do |feed|
      USER_CACHE_EXPIRATION.add_observer(feed, :expire)
      MERGED_FEEDS_EXPIRATION.add_observer(feed, :expire)
      MERGED_FEEDS[feed.name] = feed
    end

    # MyAcademics is a merged feed but shouldn't get expired by the usual observer pattern; instead it expires
    # at 8am the day after today.
    MERGED_FEEDS[MyAcademics::Merged.name] = MyAcademics::Merged

    #Pseudo-prefix constant
    PSEUDO_USER_PREFIX = "pseudo_"

  end
end


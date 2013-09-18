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
      MyUpNext
    ]
    MERGED_FEEDS = {}
    merged_feeds_array.each do |feed|
      USER_CACHE_EXPIRATION.add_observer(feed, :expire)
      MERGED_FEEDS_EXPIRATION.add_observer(feed, :expire)
      MERGED_FEEDS[feed.name] = feed
    end

    # TODO to allow us to back out CLC-2512 and preserve the old behavior, this list is separate.
    # Combine the 2 lists of merged feeds once CLC-2512 and the whole live update experience
    # are safely launched to the public.
    merged_feeds_not_expired_by_old_refresh = [
      CanvasUserSites,
      MyAcademics::Merged,
      MyRegBlocks
    ]
    merged_feeds_not_expired_by_old_refresh.each do |feed|
      MERGED_FEEDS_EXPIRATION.add_observer(feed, :expire)
      MERGED_FEEDS[feed.name] = feed
    end

    #Pseudo-prefix constant
    PSEUDO_USER_PREFIX = "pseudo_"

  end
end

